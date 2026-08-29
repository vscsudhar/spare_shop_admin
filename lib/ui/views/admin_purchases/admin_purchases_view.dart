import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_common_widgets.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_table_widgets.dart';
import 'package:stacked/stacked.dart';

import 'admin_purchases_viewmodel.dart';

class AdminPurchasesView extends StackedView<AdminPurchasesViewModel> {
  const AdminPurchasesView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AdminPurchasesViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Supplier Purchase Orders',
      selectedItem: AdminNavigationItem.purchases,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Replenishment Purchase Orders',
                  style: AdminTextStyles.sectionHeader),
              ElevatedButton.icon(
                onPressed: () => _showCreatePODialog(context, viewModel),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Create Purchase Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),

          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'All',
                'Draft',
                'Sent',
                'Received',
                'Completed',
              ].map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AdminFilterChip(
                    label: status,
                    isSelected: viewModel.selectedStatus == status,
                    onTap: () => viewModel.setSelectedStatus(status),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Ledger Table
          AdminDataTable(
            columns: const [
              'PO Number',
              'Supplier Name',
              'Parts Count',
              'Amount Total',
              'Status',
              'Expected Date',
              'Action'
            ],
            rows: viewModel.filteredPurchaseOrders.map((po) {
              return AdminTableRow(
                cells: [
                  Text(po.poNumber,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(po.supplier,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${po.itemCount} spares'),
                  Text('₹${po.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AdminStatusChip(
                      label: po.status,
                      color: _poStatusColor(po.status),
                    ),
                  ),
                  Text(po.expectedDate),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () =>
                            _showEditPODialog(context, viewModel, po),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.assignment_outlined, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () =>
                            _showChangeStatusDialog(context, viewModel, po),
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showCreatePODialog(
      BuildContext context, AdminPurchasesViewModel viewModel) {
    String? selectedSupplierId;
    String? selectedProductId;
    final quantityController = TextEditingController();
    final priceController = TextEditingController();
    final notesController = TextEditingController();
    final expectedDateController = TextEditingController();

    if (viewModel.suppliers.isNotEmpty) {
      selectedSupplierId = viewModel.suppliers.first.id;
    }
    if (viewModel.products.isNotEmpty) {
      selectedProductId = viewModel.products.first.id;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Supplier Purchase Order'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedSupplierId,
                      decoration: const InputDecoration(
                        labelText: 'Supplier',
                        border: OutlineInputBorder(),
                      ),
                      items: viewModel.suppliers.map((s) {
                        return DropdownMenuItem<String>(
                          value: s.id,
                          child: Text(s.companyName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedSupplierId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedProductId,
                      decoration: const InputDecoration(
                        labelText: 'Product',
                        border: OutlineInputBorder(),
                      ),
                      items: viewModel.products.map((p) {
                        return DropdownMenuItem<String>(
                          value: p.id,
                          child: Text(p.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedProductId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Unit Purchase Price (₹)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: expectedDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Expected Delivery Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            expectedDateController.text =
                                date.toString().split('T')[0];
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final int? qty = int.tryParse(quantityController.text);
                    final double? price = double.tryParse(priceController.text);

                    if (selectedSupplierId != null &&
                        selectedProductId != null &&
                        qty != null &&
                        price != null) {
                      try {
                        await viewModel.createPurchaseOrder(
                          supplierId: selectedSupplierId!,
                          productId: selectedProductId!,
                          quantity: qty,
                          unitPrice: price,
                          notes: notesController.text.trim(),
                          expectedDate: expectedDateController.text.trim(),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error creating PO: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill all required fields')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryGreen,
                      foregroundColor: Colors.white),
                  child: const Text('Create PO'),
                )
              ],
            );
          },
        );
      },
    );
  }

  Color _poStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return AdminColors.textLight;
      case 'submitted':
      case 'ordered':
      case 'sent':
        return AdminColors.pending;
      case 'partially_received':
      case 'received':
        return AdminColors.inProgress;
      case 'completed':
      case 'approved':
        return AdminColors.success;
      case 'cancelled':
        return Colors.red;
      default:
        return AdminColors.textSecondary;
    }
  }

  void _showEditPODialog(BuildContext context,
      AdminPurchasesViewModel viewModel, PurchaseOrderModel po) {
    String? selectedSupplierId = po.supplierId;
    String? selectedProductId = po.productId;
    final quantityController =
        TextEditingController(text: po.quantity.toString());
    final priceController =
        TextEditingController(text: po.unitPrice.toString());
    final notesController = TextEditingController(text: po.notes);
    final expectedDateController = TextEditingController(text: po.expectedDate);

    if (viewModel.suppliers.any((s) => s.id == selectedSupplierId)) {
      // Selected value is fine
    } else if (viewModel.suppliers.isNotEmpty) {
      selectedSupplierId = viewModel.suppliers.first.id;
    }

    if (viewModel.products.any((p) => p.id == selectedProductId)) {
      // Selected value is fine
    } else if (viewModel.products.isNotEmpty) {
      selectedProductId = viewModel.products.first.id;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Purchase Order: ${po.poNumber}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedSupplierId,
                      decoration: const InputDecoration(
                        labelText: 'Supplier',
                        border: OutlineInputBorder(),
                      ),
                      items: viewModel.suppliers.map((s) {
                        return DropdownMenuItem<String>(
                          value: s.id,
                          child: Text(s.companyName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedSupplierId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedProductId,
                      decoration: const InputDecoration(
                        labelText: 'Product',
                        border: OutlineInputBorder(),
                      ),
                      items: viewModel.products.map((p) {
                        return DropdownMenuItem<String>(
                          value: p.id,
                          child: Text(p.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedProductId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Unit Purchase Price (₹)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: expectedDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Expected Delivery Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.tryParse(po.expectedDate) ??
                              DateTime.now(),
                          firstDate:
                              DateTime.now().subtract(const Duration(days: 30)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            expectedDateController.text =
                                date.toString().split('T')[0];
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final int? qty = int.tryParse(quantityController.text);
                    final double? price = double.tryParse(priceController.text);

                    if (selectedSupplierId != null &&
                        selectedProductId != null &&
                        qty != null &&
                        price != null) {
                      try {
                        await viewModel.editPurchaseOrder(
                          poId: po.id,
                          supplierId: selectedSupplierId!,
                          productId: selectedProductId!,
                          quantity: qty,
                          unitPrice: price,
                          notes: notesController.text.trim(),
                          expectedDate: expectedDateController.text.trim(),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating PO: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please fill all required fields')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryGreen,
                      foregroundColor: Colors.white),
                  child: const Text('Save Changes'),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showChangeStatusDialog(BuildContext context,
      AdminPurchasesViewModel viewModel, PurchaseOrderModel po) {
    String selectedStatus = po.status.toLowerCase();
    final allowedStatuses = [
      'draft',
      'submitted',
      'approved',
      'ordered',
      'partially_received',
      'received',
      'cancelled'
    ];

    if (!allowedStatuses.contains(selectedStatus)) {
      selectedStatus = 'draft';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Change PO Status: ${po.poNumber}'),
              content: DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: allowedStatuses.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedStatus = val!;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await viewModel.changePOStatus(po.id, selectedStatus);
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating status: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryGreen,
                      foregroundColor: Colors.white),
                  child: const Text('Update Status'),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  AdminPurchasesViewModel viewModelBuilder(BuildContext context) =>
      AdminPurchasesViewModel();
}
