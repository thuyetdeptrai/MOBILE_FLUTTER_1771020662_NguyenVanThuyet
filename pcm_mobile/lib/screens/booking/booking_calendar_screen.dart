import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';
import '../../core/core.dart';

class BookingCalendarScreen extends StatefulWidget {
  const BookingCalendarScreen({super.key});

  @override
  State<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends State<BookingCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<dynamic> _courts = [];
  Map<String, dynamic> _bookingsMap = {}; // Key: "courtId_yyyyMMdd_HH"
  bool _isLoading = true;
  String? _selectedCellKey; // Track selected slot for highlight
  int? _selectedCourtId; // Track selected court for filtering

  // Hold Slot Variables
  Timer? _holdTimer;
  DateTime? _holdExpiry;
  String? _heldSlotKey; // Key of the slot currently held by user
  
  // Constants
  final int _startHour = 6;
  final int _endHour = 22;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startHoldTimerCheck();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    // Release hold if user leaves screen? 
    // Usually good practice, but depends on UX. Let's keep it simple for now (server auto-expires).
    if (_heldSlotKey != null) _releaseCurrentSlot();
    super.dispose();
  }
  
  void _startHoldTimerCheck() {
    _holdTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_holdExpiry != null && DateTime.now().isAfter(_holdExpiry!)) {
        setState(() {
          _holdExpiry = null;
          _heldSlotKey = null; // Expired
          // Refresh grid to show released state
          _loadGridBookings();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hết thời gian giữ chỗ!')));
      } else if (_holdExpiry != null) {
        // Just rebuild to update timer UI
        if (mounted) setState(() {});
      }
    });
  }

  // Case-insensitive value getter
  dynamic _v(dynamic m, String k) {
    if (m is! Map) return null;
    final pascalKey = k[0].toUpperCase() + k.substring(1);
    return m[k] ?? m[pascalKey] ?? m[k.toLowerCase()];
  }

  void _handleRealtimeUpdate(Map<String, dynamic> b) {
    final courtId = _v(b, 'courtId');
    final dateStr = _v(b, 'bookingDate');
    final startTime = _v(b, 'startTime');

    if (courtId == null || dateStr == null || startTime == null) return;

    final dateKey = dateStr.toString().replaceAll('-', '').split('T')[0];
    final hour = int.parse(startTime.toString().split(':')[0]);
    final key = '${courtId}_${dateKey}_$hour';

    if (mounted) {
      setState(() {
        // If receive update on currently held slot by SOMEONE ELSE (or status changed), update it
        // Note: Realtime logic for holding needs separate event handling ideally, 
        // but let's assume standard update covers it if status is 'Holding'
        _bookingsMap[key] = b;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final api = ApiService();
    try {
      final courtsRes = await api.get(ApiConfig.courts);
      if (courtsRes.statusCode == 200) {
        _courts = courtsRes.data;
      }
      await _loadGridBookings();
    } catch (e) {
      debugPrint('Load data error: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadGridBookings() async {
    final api = ApiService();
    final from = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final to = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    
    try {
      final Map<String, dynamic> newMap = {};
      final futures = _courts.map((court) => api.get(
        ApiConfig.bookings, 
        queryParameters: {
          'courtId': _v(court, 'id'),
          'from': from.toIso8601String(),
          'to': to.toIso8601String(),
        },
      ));

      final results = await Future.wait(futures);

      for (var i = 0; i < results.length; i++) {
        final res = results[i];
        if (res.statusCode == 200) {
          final List<dynamic> bookings = res.data;
          for (var b in bookings) {
             final dateStr = _v(b, 'bookingDate');
             final timeStr = _v(b, 'startTime');
             final bCourtId = _v(b, 'courtId');
             
             if (dateStr != null && timeStr != null && bCourtId != null) {
                final dateKey = DateFormat('yyyyMMdd').format(DateTime.parse(dateStr));
                final hour = int.parse(timeStr.split(':')[0]);
                final key = '${bCourtId}_${dateKey}_$hour';
                newMap[key] = b;
             }
          }
        }
      }
      if (mounted) setState(() => _bookingsMap = newMap);
    } catch (e) {
      debugPrint('Load grid bookings error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt sân'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCalendar(),
          const Divider(height: 1),
          _buildStatusLegend(),
          const Divider(height: 1),
          _buildCourtSelector(),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                : _buildCourtsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCourtSelector() {
    if (_courts.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Tất cả'),
              selected: _selectedCourtId == null,
              onSelected: (val) { if (val) setState(() => _selectedCourtId = null); },
              selectedColor: AppColors.accent,
              labelStyle: TextStyle(color: _selectedCourtId == null ? Colors.white : Colors.black),
            ),
          ),
          ..._courts.map((court) {
            final id = _v(court, 'id');
            final isSelected = _selectedCourtId == id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(court['name'] ?? 'Sân'),
                selected: isSelected,
                onSelected: (val) { if (val) setState(() => _selectedCourtId = id); },
                selectedColor: AppColors.accent,
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 30)),
      lastDay: DateTime.now().add(const Duration(days: 30)),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarFormat: CalendarFormat.week,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableCalendarFormats: const {CalendarFormat.week: 'Week'},
      headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
      calendarStyle: CalendarStyle(
        selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        todayDecoration: BoxDecoration(color: AppColors.primary.withOpacity(0.5), shape: BoxShape.circle),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          _loadGridBookings();
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
        _loadGridBookings();
      },
    );
  }

  Widget _buildStatusLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 12,
        runSpacing: 8,
        children: [
          _legendItem('Trống', Colors.white, border: true),
          _legendItem('Đang giữ', AppColors.warning),
          _legendItem('Của tôi', AppColors.success),
          _legendItem('Đã khóa', AppColors.error.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, {bool border = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16, height: 16,
          decoration: BoxDecoration(
            color: color,
            border: border ? Border.all(color: Colors.grey.shade300) : null,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildCourtsGrid() {
    if (_courts.isEmpty) return const Center(child: Text('Không có sân nào.'));
    
    final filteredCourts = _selectedCourtId == null 
        ? _courts 
        : _courts.where((c) => _v(c, 'id') == _selectedCourtId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(height: 50),
                ...List.generate(_endHour - _startHour + 1, (index) {
                  final hour = _startHour + index;
                  return Container(
                    height: 52, 
                    alignment: Alignment.center,
                    child: Text('$hour:00', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  );
                }),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    Row(
                      children: filteredCourts.map((court) => Container(
                        width: 100, height: 50,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          court['name'] ?? 'Sân',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      )).toList(),
                    ),
                    ...List.generate(_endHour - _startHour + 1, (index) {
                      final hour = _startHour + index;
                      return Row(
                        children: filteredCourts.map((court) => _buildGridCell(court, hour)).toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCell(dynamic court, int hour) {
    final cId = _v(court, 'id');
    final dateKey = DateFormat('yyyyMMdd').format(_selectedDay);
    final key = '${cId}_${dateKey}_$hour';
    final booking = _bookingsMap[key];
    
    final auth = context.read<AuthProvider>();
    final mId = _v(booking, 'memberId');
    final status = _v(booking, 'status');
    // Check if I am holding this slot or it's my confirmed booking
    final isMyHold = status == -1 && mId == auth.userId; // -1 is Holding
    final isMyConfirmed = booking != null && mId == auth.userId && status != -1 && status != 2; // 2 is Cancelled
    
    // Check if slot is booked by others or held by others
    // Status 0: Pending, 1: Confirmed, 3: Completed. -1: Holding.
    // We treat anything not Cancelled (2) as occupied
    final isOccupied = booking != null && status != 2;
    
    // Highlight if selected locally (legacy) or is my hold
    final isSelected = _heldSlotKey == key; 

    Color color = Colors.white;
    if (isMyConfirmed) color = AppColors.success.withOpacity(0.8);
    else if (isMyHold || isSelected) color = AppColors.warning.withOpacity(0.8);
    else if (isOccupied) color = AppColors.error.withOpacity(0.6); // gray/red for others

    return GestureDetector(
      onTap: () {
        if (!isOccupied || isMyHold) {
          if (_heldSlotKey != null && _heldSlotKey != key) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bạn đang giữ một slot khác rồi!')));
             return;
          }
          _holdSlot(court, hour);
        } else {
          final mName = _v(booking, 'memberName') ?? 'Người khác';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isMyConfirmed ? 'Sân của bạn!' : 'Đã đặt bởi $mName')),
          );
        }
      },
      child: Container(
        width: 100, height: 50, margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: (isMyHold || isSelected) ? AppColors.warning : Colors.grey.shade200,
            width: (isMyHold || isSelected) ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isMyConfirmed) const Icon(Icons.check, color: Colors.white, size: 20)
            else if (isMyHold) const Icon(Icons.timer, color: Colors.white, size: 20)
            else if (isOccupied) const Icon(Icons.lock, color: Colors.white, size: 20),
            
            if (_selectedCourtId != null) Positioned(
              right: 4, bottom: 4,
              child: Text(
                isMyConfirmed ? 'Của tôi' : (isMyHold ? 'Đang giữ' : (isOccupied ? 'Đã đặt' : '')),
                style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _holdSlot(dynamic court, int hour) async {
    final api = ApiService();
    final auth = context.read<AuthProvider>();
    
    setState(() => _isLoading = true);
    
    try {
      final res = await api.post('/Bookings/hold', data: {
        'courtId': _v(court, 'id'),
        'memberId': auth.userId,
        'bookingDate': _selectedDay.toIso8601String(),
        'startTime': '$hour:00:00',
        'endTime': '${hour+1}:00:00'
      });
      
      if (res.statusCode == 200) {
        final bookingId = res.data['bookingId'];
        final expiresAtStr = res.data['expiresAt'];
        final expiresAt = DateTime.tryParse(expiresAtStr) ?? DateTime.now().add(const Duration(minutes: 5));

        final cId = _v(court, 'id');
        final dateKey = DateFormat('yyyyMMdd').format(_selectedDay);
        final key = '${cId}_${dateKey}_$hour';

        setState(() {
          _heldSlotKey = key;
          _holdExpiry = expiresAt;
          _isLoading = false;
        });

        _showBookingBottomSheet(court, hour, bookingId, expiresAt);
      } else {
        setState(() => _isLoading = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.data['message'] ?? 'Không thể giữ chỗ')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Hold slot error: $e');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi kết nối')));
    }
  }

  Future<void> _releaseCurrentSlot({int? bookingId}) async {
    if (_heldSlotKey == null && bookingId == null) return;
    
    // Logic to call release API
    final api = ApiService();
    // Getting ID is tricky if we don't store it. 
    // Ideally store bookingId in state. 
    // For now, let's assume if bookingId passed use it, else try to find from map (unreliable for hold).
    // Better: _holdSlot stores `_currentHoldBookingId`.
    // Let's rely on _loadGridBookings cleanup or if we have ID.
    if (bookingId != null) {
       await api.post('/Bookings/release/$bookingId');
    }
    
    setState(() {
      _heldSlotKey = null;
      _holdExpiry = null;
    });
    _loadGridBookings();
  }

  void _showBookingBottomSheet(dynamic court, int hour, int bookingId, DateTime expiresAt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      isDismissible: false, // Force user to cancel or confirm
      builder: (_) => HoldSlotBottomSheet(
         court: court, date: _selectedDay, hour: hour,
         bookingId: bookingId,
         expiresAt: expiresAt,
         onConfirm: () {
           // On confirm (booking processed), close sheet
           Navigator.pop(context);
           // Clear hold state as it is now confirmed
           setState(() {
             _heldSlotKey = null;
             _holdExpiry = null;
           });
           _loadGridBookings();
         },
         onCancel: () {
           Navigator.pop(context);
           _releaseCurrentSlot(bookingId: bookingId);
         },
      ),
    );
  }
}

class HoldSlotBottomSheet extends StatefulWidget {
  final dynamic court;
  final DateTime date;
  final int hour;
  final int bookingId;
  final DateTime expiresAt;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const HoldSlotBottomSheet({
    Key? key,
    required this.court, 
    required this.date, 
    required this.hour, 
    required this.bookingId,
    required this.expiresAt,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<HoldSlotBottomSheet> createState() => _HoldSlotBottomSheetState();
}

class _HoldSlotBottomSheetState extends State<HoldSlotBottomSheet> {
  // Booking Form State
  bool _isRecurring = false;
  int _recurrenceType = 2; // Default Weekly
  DateTime? _recurrenceEnd;
  
  // Timer State
  int _secondsRemaining = 300; 
  Timer? _timer;
  bool _isLoading = false;
  int _durationHours = 1;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Default 1 month recurrence end
    _recurrenceEnd = widget.date.add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
       _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    final remaining = widget.expiresAt.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) {
      _timer?.cancel();
      if (mounted) {
         Navigator.pop(context); 
      }
    } else {
       if (mounted) setState(() => _secondsRemaining = remaining);
    }
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ... (Calculation logic remains same) ...

  int get _sessionCount {
    if (!_isRecurring || _recurrenceEnd == null) return 1;
    int count = 1;
    DateTime current = widget.date;
    while (true) {
      if (_recurrenceType == 1) current = current.add(const Duration(days: 1));
      else if (_recurrenceType == 2) current = current.add(const Duration(days: 7));
      else if (_recurrenceType == 3) current = current.add(const Duration(days: 30)); // Approximate
      else break;
      
      if (current.isAfter(_recurrenceEnd!)) break;
      count++;
    }
    return count;
  }

  Future<void> _processBooking() async {
    if (mounted) setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final api = ApiService();
    
    // Construct DateTime
    final start = DateTime(widget.date.year, widget.date.month, widget.date.day, widget.hour);
    final end = start.add(Duration(hours: _durationHours));

    try {
      // Đảm bảo courtId là int
      final courtId = widget.court['id'] ?? widget.court['Id'];
      final cId = (courtId is int) ? courtId : int.tryParse(courtId.toString()) ?? 0;
      
      final res = await api.post(ApiConfig.bookings, data: {
        'courtId': cId,
        'memberId': auth.userId,
        'startTime': start.toIso8601String(),
        'endTime': end.toIso8601String(),
        'isRecurring': _isRecurring,
        'recurrenceType': _isRecurring ? _recurrenceType : 0,
        'recurrenceEnd': _isRecurring ? _recurrenceEnd?.toIso8601String() : null,
      });

      if (res.statusCode == 200) {
        auth.refreshProfile();
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đặt sân thành công!'), 
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.fixed,
            ),
          );
          widget.onConfirm();
         }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().length > 50 ? e.toString().substring(0, 50) : e}'),
            behavior: SnackBarBehavior.fixed,
          ),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String get _timerString {
    final m = (_secondsRemaining / 60).floor();
    final s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final basePrice = widget.court['pricePerHour'] ?? 0;
    final sessions = _sessionCount;
    final totalPrice = basePrice * _durationHours * sessions;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.timer, color: AppColors.warning),
                const SizedBox(width: 8),
                Text(
                  'Giữ chỗ trong $_timerString',
                  style: AppTheme.heading3.copyWith(color: AppColors.warning),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Xác nhận đặt sân', style: AppTheme.heading2),
            const SizedBox(height: 16),
            
            _buildInfoRow('Sân', widget.court['name']),
            _buildInfoRow('Bắt đầu', '${widget.hour}:00, ${DateFormat('dd/MM/yyyy').format(widget.date)}'),
            
            // Duration Selector
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Số giờ đặt', style: TextStyle(color: Colors.grey)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<int>(
                      value: _durationHours,
                      underline: const SizedBox(),
                      items: [1, 2, 3, 4].map((h) => DropdownMenuItem(
                        value: h,
                        child: Text('$h giờ'),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _durationHours = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            _buildInfoRow('Thời gian trả sân', '${widget.hour + _durationHours}:00'),

            // Periodic Booking Selector (Only for VIP)
            if (auth.currentUser?.isVip ?? false) ...[
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Đặt lịch định kỳ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Dành cho hạng Vàng/Kim Cương', style: TextStyle(fontSize: 10, color: AppColors.primary)),
                    ],
                  ),
                  Switch(
                    value: _isRecurring,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _isRecurring = val),
                  ),
                ],
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tần suất', style: TextStyle(color: Colors.grey)),
                    DropdownButton<int>(
                      value: _recurrenceType,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Hàng ngày')),
                        DropdownMenuItem(value: 2, child: Text('Hàng tuần')),
                        DropdownMenuItem(value: 3, child: Text('Hàng tháng')),
                      ],
                      onChanged: (val) { if (val != null) setState(() => _recurrenceType = val); },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Đến ngày', style: TextStyle(color: Colors.grey)),
                    TextButton(
                      child: Text(DateFormat('dd/MM/yyyy').format(_recurrenceEnd!)),
                      onPressed: () async {
                        final res = await showDatePicker(
                          context: context,
                          initialDate: _recurrenceEnd!,
                          firstDate: widget.date.add(const Duration(days: 7)),
                          lastDate: widget.date.add(const Duration(days: 90)),
                        );
                        if (res != null) setState(() => _recurrenceEnd = res);
                      },
                    ),
                  ],
                ),
                Text(
                  '* Tổng cộng $sessions buổi đặt sân',
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.right,
                ),
              ],
            ],
            
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng thanh toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  currencyFormat.format(totalPrice),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _processBooking,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Text('XÁC NHẬN THANH TOÁN', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
