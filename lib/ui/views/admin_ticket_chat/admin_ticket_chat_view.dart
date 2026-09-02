import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/admin_support_ticket_models.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:stacked/stacked.dart';

import 'admin_ticket_chat_viewmodel.dart';

class AdminTicketChatView extends StackedView<AdminTicketChatViewModel> {
  final String ticketId;

  const AdminTicketChatView({
    Key? key,
    this.ticketId = '',
  }) : super(key: key);

  @override
  void onViewModelReady(AdminTicketChatViewModel viewModel) {
    if (ticketId.isNotEmpty) {
      viewModel.initialize(ticketId);
    }
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    AdminTicketChatViewModel viewModel,
    Widget? child,
  ) {
    if (ticketId.isEmpty) {
      return AdminShell(
        title: 'Support Ticket',
        selectedItem: AdminNavigationItem.supportTickets,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.confirmation_number_outlined,
                    size: 48, color: Colors.white54),
                const SizedBox(height: 16),
                const Text(
                  'No ticket selected. Please select a ticket from the tickets list.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.goBack(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Back to Tickets'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final ticket = viewModel.ticket;

    if (viewModel.errorMessage != null) {
      return AdminShell(
        title: 'Support Ticket',
        selectedItem: AdminNavigationItem.supportTickets,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: AdminColors.cancelled, size: 48),
                const SizedBox(height: 16),
                Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: AdminColors.cancelled, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => viewModel.loadTicket(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (ticket == null) {
      return AdminShell(
        title: 'Support Ticket',
        selectedItem: AdminNavigationItem.supportTickets,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80.0),
            child: CircularProgressIndicator(color: AdminColors.primaryGreen),
          ),
        ),
      );
    }

    final status = ticket.status;

    return AdminShell(
      title: 'Support Ticket: #${ticket.ticketNumber}',
      selectedItem: AdminNavigationItem.supportTickets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button & Status controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => viewModel.goToAdminSupportTickets(),
                icon: Icon(Icons.arrow_back,
                    size: 16, color: AdminColors.textSecondary),
                label: Text('Back to Tickets List',
                    style: TextStyle(color: AdminColors.textSecondary)),
              ),
              Row(
                children: [
                  Text('Status: ',
                      style: TextStyle(
                          color: AdminColors.textPrimary,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AdminColors.panelBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AdminColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: status.name,
                        dropdownColor: AdminColors.panelBackground,
                        items:
                            ['open', 'pending', 'resolved', 'closed'].map((s) {
                          return DropdownMenuItem<String>(
                            value: s,
                            child: Text(
                              s.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AdminTicketStatus.fromString(s).color,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null) {
                            viewModel.updateStatus(newStatus);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (status != AdminTicketStatus.resolved &&
                      status != AdminTicketStatus.closed)
                    ElevatedButton.icon(
                      onPressed: () => viewModel.updateStatus('resolved'),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Resolve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B156),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => viewModel.updateStatus('open'),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Reopen'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AdminColors.primaryGreen,
                        side: BorderSide(color: AdminColors.primaryGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Two-column layout: Left Chat Room, Right Customer Info & Ticket Summary
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Chat Conversation Room
                  Expanded(
                    flex: isWide ? 2 : 3,
                    child: Container(
                      height: 600,
                      decoration: BoxDecoration(
                        color: AdminColors.panelBackground,
                        borderRadius: BorderRadius.circular(AdminRadius.card),
                        border: Border.all(color: AdminColors.border),
                      ),
                      child: Column(
                        children: [
                          // Conversation Header
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AdminColors.background,
                              border: Border(
                                  bottom:
                                      BorderSide(color: AdminColors.border)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.headset_mic_rounded,
                                    color: AdminColors.primaryGreen, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ticket.subject,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      ),
                                      Text(
                                        'Category: ${ticket.category}  •  Customer: ${ticket.customerName}',
                                        style: TextStyle(
                                            color: AdminColors.textSecondary,
                                            fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Messages List
                          Expanded(
                            child: viewModel.messages.isEmpty
                                ? Center(
                                    child: Text(
                                      'No messages yet in this ticket conversation.',
                                      style: TextStyle(
                                          color: AdminColors.textSecondary,
                                          fontSize: 13),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: viewModel.scrollController,
                                    padding: const EdgeInsets.all(16),
                                    itemCount: viewModel.messages.length,
                                    itemBuilder: (context, index) {
                                      final msg = viewModel.messages[index];
                                      return _buildMessageBubble(context, msg);
                                    },
                                  ),
                          ),

                          // Selected photo preview bar
                          if (viewModel.selectedPhotos.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(8),
                              color: AdminColors.background,
                              child: Row(
                                children: viewModel.selectedPhotos
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final idx = entry.key;
                                  final photo = entry.value;
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: AdminColors.border),
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          child: kIsWeb
                                              ? Image.network(photo.path,
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover)
                                              : Image.file(File(photo.path),
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover),
                                        ),
                                        Positioned(
                                          top: 2,
                                          right: 2,
                                          child: GestureDetector(
                                            onTap: () =>
                                                viewModel.removePhoto(idx),
                                            child: const Icon(Icons.close,
                                                size: 14, color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                          // Reply Input Bar
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AdminColors.background,
                              border: Border(
                                  top: BorderSide(color: AdminColors.border)),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  tooltip: 'Attach photo',
                                  icon: Icon(Icons.attach_file_rounded,
                                      color: AdminColors.textSecondary,
                                      size: 20),
                                  onPressed: viewModel.pickPhoto,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: viewModel.messageController,
                                    onSubmitted: (_) =>
                                        viewModel.sendMessage(),
                                    decoration: InputDecoration(
                                      hintText: 'Type admin response...',
                                      hintStyle: TextStyle(
                                          color: AdminColors.textSecondary,
                                          fontSize: 13),
                                      filled: true,
                                      fillColor: AdminColors.panelBackground,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 10),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: AdminColors.border),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: AdminColors.border),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: viewModel.isSending
                                      ? null
                                      : viewModel.sendMessage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AdminColors.primaryGreen,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: viewModel.isSending
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.send_rounded,
                                          size: 14),
                                  label: const Text('Reply'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (isWide) const SizedBox(width: 20),

                  // Right Column: Customer Info & Details Summary
                  if (isWide)
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AdminColors.panelBackground,
                              borderRadius:
                                  BorderRadius.circular(AdminRadius.card),
                              border: Border.all(color: AdminColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Customer Details',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 12),
                                _infoRow('Name', ticket.customerName),
                                _infoRow(
                                    'Email',
                                    ticket.customerEmail.isNotEmpty
                                        ? ticket.customerEmail
                                        : '—'),
                                _infoRow(
                                    'Phone',
                                    ticket.customerPhone.isNotEmpty
                                        ? ticket.customerPhone
                                        : '—'),
                                Divider(color: AdminColors.border, height: 24),
                                const Text('Ticket Information',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 12),
                                _infoRow('Ticket #', '#${ticket.ticketNumber}'),
                                _infoRow('Category', ticket.category),
                                _infoRow(
                                    'Priority', ticket.priority.toUpperCase()),
                                _infoRow('Status', status.displayName),
                                _infoRow(
                                    'Created',
                                    '${ticket.createdAt.day.toString().padLeft(2, '0')}/${ticket.createdAt.month.toString().padLeft(2, '0')}/${ticket.createdAt.year}'),
                                const SizedBox(height: 12),
                                Text('Initial Description:',
                                    style: TextStyle(
                                        color: AdminColors.textSecondary,
                                        fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(
                                  ticket.description,
                                  style: const TextStyle(
                                      fontSize: 13, height: 1.3),
                                ),

                                // Customer initial photos
                                if (ticket.photos.isNotEmpty) ...[
                                  Divider(
                                      color: AdminColors.border, height: 24),
                                  Text('Attached Photos (${ticket.photos.length})',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: ticket.photos.map((photo) {
                                      final url =
                                          AdminTicketChatViewModel.formatImageUrl(
                                              photo.url);
                                      return InkWell(
                                        onTap: () => _openImageDialog(
                                            context, url),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            url,
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                              width: 70,
                                              height: 70,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                  Icons.broken_image,
                                                  size: 24,
                                                  color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: AdminColors.textSecondary, fontSize: 12)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, AdminTicketMessage msg) {
    final isAdmin = msg.isAdminOrStaff;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isAdmin) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AdminColors.border,
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isAdmin
                    ? AdminColors.primaryGreen.withValues(alpha: 0.15)
                    : AdminColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isAdmin
                      ? AdminColors.primaryGreen.withValues(alpha: 0.3)
                      : AdminColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    isAdmin ? 'Admin / Support' : msg.senderName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isAdmin
                          ? AdminColors.primaryGreen
                          : AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg.message,
                    style: const TextStyle(fontSize: 13, height: 1.3),
                  ),
                  if (msg.attachments.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: msg.attachments.map((att) {
                        final formattedUrl =
                            AdminTicketChatViewModel.formatImageUrl(att.url);
                        return InkWell(
                          onTap: () =>
                              _openImageDialog(context, formattedUrl),
                          borderRadius: BorderRadius.circular(6),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              formattedUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                        fontSize: 9, color: AdminColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: AdminColors.primaryGreen,
              child: const Icon(Icons.support_agent,
                  size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  void _openImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 800, maxHeight: 650),
              decoration: BoxDecoration(
                color: AdminColors.panelBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: Text('Failed to load image',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(ctx).pop(),
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  AdminTicketChatViewModel viewModelBuilder(BuildContext context) =>
      AdminTicketChatViewModel();
}
