import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:signalr_netcore/signalr_netcore.dart'; // <--- Thư viện Real-time

class WalletScreen extends StatefulWidget {
  final String userId;
  const WalletScreen({super.key, required this.userId});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double balance = 0;
  List<dynamic> history = [];
  bool isLoading = true;
  final TextEditingController _amountController = TextEditingController();

  File? _selectedImage;
  bool isUploading = false;

  // Biến SignalR
  late HubConnection hubConnection;

  @override
  void initState() {
    super.initState();
    fetchWalletInfo();
    initSignalR(); // <--- Kích hoạt Real-time
  }

  @override
  void dispose() {
    hubConnection.stop(); // Tắt kết nối khi thoát màn hình
    super.dispose();
  }

  // --- KẾT NỐI REAL-TIME (QUAN TRỌNG) ---
  Future<void> initSignalR() async {
    // Lưu ý: Nếu chạy máy ảo Android thì đổi localhost thành 10.0.2.2
    const serverUrl = "http://localhost:5176/pcmHub";

    hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();

    // 1. Kết nối đến Server
    await hubConnection.start();
    print("SignalR Connected!");

    // 2. Báo danh với Server (Join Room theo UserId)
    await hubConnection.invoke("JoinRoom", args: [widget.userId]);

    // 3. Lắng nghe sự kiện "ReceiveNotification" từ Server
    hubConnection.on("ReceiveNotification", (arguments) {
      final message = arguments![0] as String;
      final newBalance = (arguments[1] as num).toDouble();

      // Cập nhật giao diện ngay lập tức
      if (mounted) {
        setState(() {
          balance = newBalance; // Nhảy số dư mới
        });

        // Hiện thông báo (SnackBar)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

        // Tải lại lịch sử để hiện dòng "Thành công"
        fetchWalletInfo();
      }
    });
  }
  // ---------------------------------------

  Future<void> fetchWalletInfo() async {
    final url = Uri.parse('http://localhost:5176/api/Wallet/${widget.userId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            balance = (data['Balance'] as num).toDouble();
            history = data['History'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;
    final url = Uri.parse('http://localhost:5176/api/Upload');
    final request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath('file', _selectedImage!.path),
    );
    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode == 200) return jsonDecode(response.body)['url'];
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> _processDeposit() async {
    if (_amountController.text.isEmpty) return;
    String? evidenceUrl;
    if (_selectedImage != null) {
      setState(() => isUploading = true);
      evidenceUrl = await _uploadImage();
      setState(() => isUploading = false);
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount < 10000) return;

    final url = Uri.parse('http://localhost:5176/api/Wallet/deposit');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "memberId": widget.userId,
          "amount": amount,
          "evidenceUrl": evidenceUrl ?? "",
        }),
      );
      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gửi yêu cầu thành công! Đang chờ duyệt..."),
            backgroundColor: Colors.orange,
          ),
        );
        _amountController.clear();
        setState(() => _selectedImage = null);
        fetchWalletInfo();
      }
    } catch (e) {
      print(e);
    }
  }

  void _showDepositDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Nạp tiền chuyển khoản"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Số tiền",
                    suffixText: "đ",
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    await _pickImage();
                    setStateDialog(() {});
                  },
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedImage == null
                        ? const Icon(Icons.camera_alt, color: Colors.grey)
                        : Image.file(_selectedImage!, fit: BoxFit.cover),
                  ),
                ),
                if (isUploading) const LinearProgressIndicator(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy"),
              ),
              ElevatedButton(
                onPressed: _processDeposit,
                child: const Text("Gửi Yêu Cầu"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ví Của Tôi"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.deepPurpleAccent],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Số dư khả dụng",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        currencyFormat.format(balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ), // <--- SỐ NÀY SẼ TỰ NHẢY
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_card),
                        label: const Text("NẠP TIỀN"),
                        onPressed: _showDepositDialog,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      final isSuccess = item['status'] == 1;
                      return ListTile(
                        leading: Icon(
                          isSuccess ? Icons.check_circle : Icons.access_time,
                          color: isSuccess ? Colors.green : Colors.orange,
                        ),
                        title: Text(item['description']),
                        subtitle: Text(
                          DateFormat(
                            'dd/MM HH:mm',
                          ).format(DateTime.parse(item['createdDate'])),
                        ),
                        trailing: Text(
                          "${item['amount']}đ",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
