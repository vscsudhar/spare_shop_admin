import 'package:spare_shop_admin/ui/common/voltspare_models.dart';

class RareRequestMockService {
  static final List<RareProductRequestModel> _requests = [
    RareProductRequestModel(
      id: 'req_101',
      customerName: 'Suresh Kumar',
      phone: '+91 98765 43210',
      vehicle: const VehicleModel(
        id: 'veh_ather_450x',
        brand: 'Ather',
        name: '450X Gen 3',
        year: '2022',
        type: VehicleType.ev,
      ),
      partName: 'Ather High-Tension Belt Tensioner Pulley',
      description:
          'The tensioner pulley for the high-tension drive belt has developed a crack and squeals during startup. Needs replacement urgent.',
      quantity: 1,
      urgency: 'Urgent',
      budget: 1500.0,
      images: ['https://voltspare.com/placeholder_pulley.jpg'],
      status: RareRequestStatus.submitted,
      date: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    RareProductRequestModel(
      id: 'req_102',
      customerName: 'Ravi Verma',
      phone: '+91 99000 88000',
      vehicle: const VehicleModel(
        id: 'veh_ola_s1',
        brand: 'Ola',
        name: 'S1 Pro Gen 2',
        year: '2023',
        type: VehicleType.ev,
      ),
      partName: 'Ola S1 Pro Gen 2 Side Stand Sensor',
      description:
          'Side stand sensor replacement. Current one is malfunctioning and keeps showing stand is down even when retracted.',
      quantity: 1,
      urgency: 'Normal',
      budget: 800.0,
      images: [],
      status: RareRequestStatus.quotationSent,
      date: DateTime.now().subtract(const Duration(days: 2)),
      quotation: RareQuotationModel(
        id: 'q_102',
        partName: 'Ola S1 Pro Gen 2 Side Stand Sensor assembly',
        price: 750.0,
        shippingCharge: 50.0,
        gst: 144.0,
        discount: 44.0,
        grandTotal: 900.0,
        deliveryTimeline: '3 Days Delivery',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
        adminNotes:
            'Genuine Ola OEM spare part with stand mounting spring included.',
        status: 'pending',
      ),
    ),
    RareProductRequestModel(
      id: 'req_103',
      customerName: 'Anjali Sharma',
      phone: '+91 97777 66666',
      vehicle: const VehicleModel(
        id: 'veh_honda_activa',
        brand: 'Honda',
        name: 'Activa 6G',
        year: '2022',
        type: VehicleType.petrol,
      ),
      partName: 'Honda Activa Rear Suspension Dampers',
      description:
          'Upgraded rear suspension nitrogen gas-charged dampers for better comfort over potholes.',
      quantity: 2,
      urgency: 'Normal',
      images: [],
      status: RareRequestStatus.approved,
      date: DateTime.now().subtract(const Duration(days: 5)),
      quotation: RareQuotationModel(
        id: 'q_103',
        partName: 'Endurance Nitrox Rear Dampers Set',
        price: 2200.0,
        shippingCharge: 100.0,
        gst: 414.0,
        discount: 214.0,
        grandTotal: 2500.0,
        deliveryTimeline: '1 Week Delivery',
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        adminNotes: 'Endurance Nitrox pair set. Perfect upgrade compatibility.',
        status: 'approved',
      ),
    ),
  ];

  static final Map<String, List<RareChatMessageModel>> _chats = {
    'req_101': [
      RareChatMessageModel(
        id: 'm_1',
        message:
            'Hello, I have submitted the request for the Ather belt tensioner. Can you please check if it is available?',
        sender: RareChatSender.customer,
        timestamp: DateTime.now().subtract(const Duration(hours: 11)),
        messageType: RareChatMessageType.text,
      ),
      RareChatMessageModel(
        id: 'm_2',
        message:
            'Sure Suresh! We are checking our supplier logs for this tensioner. We will notify you as soon as we find it.',
        sender: RareChatSender.admin,
        timestamp: DateTime.now().subtract(const Duration(hours: 10)),
        messageType: RareChatMessageType.text,
      ),
    ],
    'req_102': [
      RareChatMessageModel(
        id: 'm_102_1',
        message:
            'Malfunctioning stand sensor on Ola S1. Let me know if you can find one.',
        sender: RareChatSender.customer,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        messageType: RareChatMessageType.text,
      ),
      RareChatMessageModel(
        id: 'm_102_2',
        message:
            'We have located the genuine Ola stand sensor assembly from our Chennai warehouse. Sending the quotation details.',
        sender: RareChatSender.admin,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        messageType: RareChatMessageType.text,
      ),
      RareChatMessageModel(
        id: 'm_102_3',
        message: 'Quotation of ₹900 generated.',
        sender: RareChatSender.system,
        timestamp: DateTime.now().subtract(const Duration(hours: 20)),
        messageType: RareChatMessageType.statusUpdate,
      ),
    ],
    'req_103': [
      RareChatMessageModel(
        id: 'm_103_1',
        message: 'Quotation approved by Suresh.',
        sender: RareChatSender.system,
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
        messageType: RareChatMessageType.statusUpdate,
      ),
    ],
  };

  List<RareProductRequestModel> getRequests() {
    return _requests;
  }

  RareProductRequestModel? getRequestById(String id) {
    final index = _requests.indexWhere((r) => r.id == id);
    return index != -1 ? _requests[index] : null;
  }

  List<RareChatMessageModel> getMessages(String requestId) {
    return _chats[requestId] ?? [];
  }

  void submitRequest(RareProductRequestModel request) {
    _requests.insert(0, request);
    _chats[request.id] = [
      RareChatMessageModel(
        id: 'msg_init_${request.id}',
        message:
            'New request submitted: ${request.partName ?? "Unknown part"}. Description: ${request.description}',
        sender: RareChatSender.system,
        timestamp: DateTime.now(),
        messageType: RareChatMessageType.statusUpdate,
      )
    ];
  }

  void addMessage(String requestId, RareChatMessageModel message) {
    if (!_chats.containsKey(requestId)) {
      _chats[requestId] = [];
    }
    _chats[requestId]!.add(message);

    // If customer sends a message after status converted to found or quotationSent, let it be.
    // If it's a new message, we can reactively notify listeners.
  }

  void sendQuotation(String requestId, RareQuotationModel quotation) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(
        status: RareRequestStatus.quotationSent,
        quotation: quotation,
      );

      addMessage(
        requestId,
        RareChatMessageModel(
          id: 'msg_q_${quotation.id}',
          message: 'Quotation sent for ${quotation.partName}',
          sender: RareChatSender.admin,
          timestamp: DateTime.now(),
          messageType: RareChatMessageType.quotation,
          quotation: quotation,
        ),
      );
    }
  }

  void approveQuotation(String requestId) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final req = _requests[index];
      if (req.quotation != null) {
        final updatedQuotation = RareQuotationModel(
          id: req.quotation!.id,
          partName: req.quotation!.partName,
          price: req.quotation!.price,
          shippingCharge: req.quotation!.shippingCharge,
          gst: req.quotation!.gst,
          discount: req.quotation!.discount,
          grandTotal: req.quotation!.grandTotal,
          deliveryTimeline: req.quotation!.deliveryTimeline,
          expiryDate: req.quotation!.expiryDate,
          adminNotes: req.quotation!.adminNotes,
          status: 'approved',
        );

        _requests[index] = req.copyWith(
          status: RareRequestStatus.approved,
          quotation: updatedQuotation,
        );

        addMessage(
          requestId,
          RareChatMessageModel(
            id: 'msg_approved_${DateTime.now().millisecondsSinceEpoch}',
            message:
                'Quotation approved by customer. Total amount: ₹${req.quotation!.grandTotal}',
            sender: RareChatSender.system,
            timestamp: DateTime.now(),
            messageType: RareChatMessageType.statusUpdate,
          ),
        );
      }
    }
  }

  void cancelQuotation(String requestId, String reason) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final req = _requests[index];
      final updatedQuotation = req.quotation != null
          ? RareQuotationModel(
              id: req.quotation!.id,
              partName: req.quotation!.partName,
              price: req.quotation!.price,
              shippingCharge: req.quotation!.shippingCharge,
              gst: req.quotation!.gst,
              discount: req.quotation!.discount,
              grandTotal: req.quotation!.grandTotal,
              deliveryTimeline: req.quotation!.deliveryTimeline,
              expiryDate: req.quotation!.expiryDate,
              adminNotes: req.quotation!.adminNotes,
              status: 'declined',
            )
          : null;

      _requests[index] = req.copyWith(
        status: RareRequestStatus.cancelled,
        quotation: updatedQuotation,
        cancellationReason: reason,
      );

      addMessage(
        requestId,
        RareChatMessageModel(
          id: 'msg_cancelled_${DateTime.now().millisecondsSinceEpoch}',
          message: 'Request cancelled. Reason: $reason',
          sender: RareChatSender.system,
          timestamp: DateTime.now(),
          messageType: RareChatMessageType.statusUpdate,
        ),
      );
    }
  }

  void reopenRequest(String requestId) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(
        status: RareRequestStatus.negotiation,
        cancellationReason: null,
      );

      addMessage(
        requestId,
        RareChatMessageModel(
          id: 'msg_reopened_${DateTime.now().millisecondsSinceEpoch}',
          message: 'Request reopened for revised quotation negotiations.',
          sender: RareChatSender.system,
          timestamp: DateTime.now(),
          messageType: RareChatMessageType.statusUpdate,
        ),
      );
    }
  }

  void updateStatus(String requestId, RareRequestStatus status) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(status: status);
      addMessage(
        requestId,
        RareChatMessageModel(
          id: 'msg_status_${DateTime.now().millisecondsSinceEpoch}',
          message: 'Status updated to: ${status.name.toUpperCase()}',
          sender: RareChatSender.system,
          timestamp: DateTime.now(),
          messageType: RareChatMessageType.statusUpdate,
        ),
      );
    }
  }
}
