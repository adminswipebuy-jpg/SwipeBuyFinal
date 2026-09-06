import 'package:flutter/material.dart';
import '../services/professional_booking_service.dart';
import '../services/auth_service.dart';

class ProfessionalBookingPage extends StatefulWidget {
  final Map<String, dynamic>? service;
  const ProfessionalBookingPage({super.key, this.service});
  @override State<ProfessionalBookingPage> createState() => _ProfessionalBookingPageState();
}

class _ProfessionalBookingPageState extends State<ProfessionalBookingPage> {
  final api = ProfessionalBookingService();
  final note = TextEditingController();
  DateTime requested = DateTime.now().add(const Duration(hours: 24));
  int duration = 60;
  bool submitting = false;

  @override Widget build(BuildContext context) {
    final service = widget.service;
    return Scaffold(
      appBar: AppBar(title: const Text('Professional Booking')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (service != null) Card(child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.handyman_outlined)),
          title: Text((service['title'] ?? 'Professional service').toString(), style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text('${service['providerName'] ?? 'Provider'} • From ${service['startingPrice'] ?? 'Quote'}'),
        )),
        const SizedBox(height: 12),
        const Text('Request a time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        ListTile(leading: const Icon(Icons.calendar_today_outlined), title: Text(_format(requested)), trailing: const Icon(Icons.chevron_right), onTap: _pickDateTime),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(value: duration, items: const [30,60,90,120].map((m)=>DropdownMenuItem(value:m, child: Text('$m minutes'))).toList(), onChanged:(v)=>setState(()=>duration=v??60), decoration: const InputDecoration(labelText:'Duration')),
        const SizedBox(height: 12),
        TextField(controller: note, maxLines: 4, decoration: const InputDecoration(labelText: 'Project / appointment notes', hintText: 'Tell the professional what you need...')),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.shield_outlined), SizedBox(width: 10), Expanded(child: Text('Booking, contract, payment and cancellation status are confirmed by backend workflows. This request does not charge your payment method.'))])),
        const SizedBox(height: 18),
        FilledButton.icon(onPressed: submitting ? null : _submit, icon: const Icon(Icons.calendar_month), label: Text(submitting ? 'Submitting…' : 'Request booking')),
        const SizedBox(height: 24),
        const Text('My bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        StreamBuilder<List<Map<String,dynamic>>>(stream: api.streamMyBookings(), builder:(context,snap){
          final rows=snap.data??const <Map<String,dynamic>>[];
          if(AuthService.currentUser==null) return const Text('Sign in to manage professional bookings.', style: TextStyle(color: Colors.white60));
          if(rows.isEmpty) return const Padding(padding: EdgeInsets.all(18), child: Text('No bookings yet.', style: TextStyle(color: Colors.white60)));
          return Column(children: rows.map((r)=>Card(child: ListTile(title: Text((r['providerName']??'Provider').toString()), subtitle: Text('${r['status'] ?? 'pending'} • ${r['contractStatus'] ?? 'not started'}'), trailing: PopupMenuButton<String>(onSelected:(v) async{ if(v=='contract'){ await api.requestContract(bookingId:r['id'].toString()); } else if(v=='cancel'){ await api.cancelBooking(bookingId:r['id'].toString()); } if(mounted) setState((){}); }, itemBuilder:(_)=>const [PopupMenuItem(value:'contract',child:Text('Request contract')),PopupMenuItem(value:'cancel',child:Text('Request cancellation'))])))).toList());
        })
      ]),
    );
  }

  Future<void> _submit() async {
    final service = widget.service;
    if (service == null) return;
    setState(()=>submitting=true);
    await api.requestBooking(serviceId: service['id'].toString(), providerName: (service['providerName']??'Provider').toString(), requestedStart: requested, durationMinutes: duration, note: note.text);
    if (mounted) { setState(()=>submitting=false); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking request submitted for provider confirmation.'))); Navigator.pop(context); }
  }

  Future<void> _pickDateTime() async {
    final d=await showDatePicker(context:context, firstDate:DateTime.now(), lastDate:DateTime.now().add(const Duration(days:180)), initialDate:requested);
    if(d==null||!mounted)return;
    final t=await showTimePicker(context:context, initialTime:TimeOfDay.fromDateTime(requested));
    if(t==null)return;
    setState(()=>requested=DateTime(d.year,d.month,d.day,t.hour,t.minute));
  }
  String _format(DateTime d) => '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
}
