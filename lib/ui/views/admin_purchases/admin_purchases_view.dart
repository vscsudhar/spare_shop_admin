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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Replenishment Purchase Orders',
                      style: AdminTextStyles.sectionHeader),
                  const SizedBox(height: 4),
                  Text(
                    'Manage supplier replenishment orders and fulfillment hub destinations',
                    style: AdminTextStyles.bodySecondary.copyWith(fontSize: 12),
                  ),
                ],
              ),
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

          // Location Filter Section & Hub Quick Selector
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AdminColors.panelBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AdminColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: AdminColors.primaryGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Destination Hub Filter:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    if (!viewModel.canChangeLocation &&
                        viewModel.userAssignedLocationName != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock, size: 12, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              'Scoped to ${viewModel.userAssignedLocationName}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      AdminFilterChip(
                        label: 'All Hubs (HQ)',
                        isSelected: viewModel.selectedLocationFilter == 'all',
                        onTap: () => viewModel.setSelectedLocationFilter('all'),
                      ),
                      ...viewModel.locations.map((loc) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: AdminFilterChip(
                            label: '${loc.name} Hub',
                            isSelected:
                                viewModel.selectedLocationFilter == loc.id,
                            onTap: () =>
                                viewModel.setSelectedLocationFilter(loc.id),
                          ),
                        );
                      }),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: AdminFilterChip(
                          label: viewModel.unassignedPOCount > 0
                              ? '⚠️ Unassigned (${viewModel.unassignedPOCount})'
                              : 'Unassigned',
                          isSelected:
                              viewModel.selectedLocationFilter == 'unassigned',
                          onTap: () =>
                              viewModel.setSelectedLocationFilter('unassigned'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

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
              'Destination Hub',
              'Parts Count',
              'Amount Total',
              'Status',
              'Expected Date',
              'Action'
            ],
            rows: viewModel.filteredPurchaseOrders.map((po) {
              final hasLocation = po.locationName != null &&
                  po.locationName!.isNotEmpty;
              return AdminTableRow(
                cells: [
                  Text(po.poNumber,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(po.supplier,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: hasLocation
                        ? InkWell(
                            onTap: () =>
                                _showAssignLocationDialog(context, viewModel, po),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AdminColors.primaryGreen
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: AdminColors.primaryGreen
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on,
                                      size: 13,
                                      color: AdminColors.primaryGreen),
                                  const SizedBox(width: 4),
                                  Text(
                                    po.locationName!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AdminColors.primaryGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_drop_down,
                                      size: 14, color: Colors.white54),
                                ],
                              ),
                            ),
                          )
                        : OutlinedButton.icon(
                            onPressed: () =>
                                _showAssignLocationDialog(context, viewModel, po),
                            icon: const Icon(Icons.add_location_alt,
                                size: 12, color: Colors.amber),
                            label: const Text(
                              '+ Add Hub',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.amber),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.amber.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                  ),
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
    String? selectedLocationId = viewModel.userAssignedLocationId;
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
    if (selectedLocationId == null && viewModel.locations.isNotEmpty) {
      selectedLocationId = viewModel.locations.first.id;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AdminColors.panelBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    // Destination Hub Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedLocationId,
                      decoration: const InputDecoration(
                        labelText: 'Destination Hub / Warehouse',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Unassigned (HQ Default)'),
                        ),
                        ...viewModel.locations.map((loc) {
                          return DropdownMenuItem<String>(
                            value: loc.id,
                            child: Text('${loc.name} Hub'),
                          );
                        }),
                      ],
                      onChanged: viewModel.canChangeLocation
                          ? (val) {
                              setState(() {
                                selectedLocationId = val;
                              });
                            }
                          : null,
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
                        String? locName;
                        if (selectedLocationId != null) {
                          final locMatch = viewModel.locations
                              .where((l) => l.id == selectedLocationId);
                          if (locMatch.isNotEmpty) {
                            locName = locMatch.first.name;
                          }
                        }

                        await viewModel.createPurchaseOrder(
                          supplierId: selectedSupplierId!,
                          productId: selectedProductId!,
                          quantity: qty,
                          unitPrice: price,
                          locationId: selectedLocationId,
                          locationName: locName,
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
    String? selectedLocationId = po.locationId;
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
              backgroundColor: AdminColors.panelBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    // Destination Hub Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedLocationId,
                      decoration: const InputDecoration(
                        labelText: 'Destination Hub / Warehouse',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Unassigned (HQ Default)'),
                        ),
                        ...viewModel.locations.map((loc) {
                          return DropdownMenuItem<String>(
                            value: loc.id,
                            child: Text('${loc.name} Hub'),
                          );
                        }),
                      ],
                      onChanged: viewModel.canChangeLocation
                          ? (val) {
                              setState(() {
                                selectedLocationId = val;
                              });
                            }
                          : null,
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
                        String? locName;
                        if (selectedLocationId != null) {
                          final locMatch = viewModel.locations
                              .where((l) => l.id == selectedLocationId);
                          if (locMatch.isNotEmpty) {
                            locName = locMatch.first.name;
                          }
                        }

                        await viewModel.editPurchaseOrder(
                          poId: po.id,
                          supplierId: selectedSupplierId!,
                          productId: selectedProductId!,
                          quantity: qty,
                          unitPrice: price,
                          locationId: selectedLocationId,
                          locationName: locName,
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

  void _showAssignLocationDialog(
    BuildContext context,
    AdminPurchasesViewModel viewModel,
    PurchaseOrderModel po,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AdminColors.panelBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.location_on, color: AdminColors.primaryGreen, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Assign Destination Hub for ${po.poNumber}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Supplier: ${po.supplier}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      if (po.locationName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Current Destination: ${po.locationName}',
                          style: TextStyle(
                              fontSize: 11,
                              color: AdminColors.primaryGreen,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Fulfillment Destination Hub:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (viewModel.locations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'No locations registered in system. Please create locations in Locations Management.',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: viewModel.locations.length,
                      separatorBuilder: (_, __) => const Divider(height: 8),
                      itemBuilder: (context, index) {
                        final loc = viewModel.locations[index];
                        final isCurrent = po.locationId == loc.id ||
                            po.locationName?.toLowerCase() ==
                                loc.name.toLowerCase();
                        return ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          tileColor: isCurrent
                              ? AdminColors.primaryGreen.withValues(alpha: 0.15)
                              : Colors.transparent,
                          leading: Icon(
                            Icons.storefront_outlined,
                            size: 18,
                            color: isCurrent
                                ? AdminColors.primaryGreen
                                : Colors.white70,
                          ),
                          title: Text(
                            '${loc.name} Hub',
                            style: TextStyle(
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isCurrent
                                  ? AdminColors.primaryGreen
                                  : Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            'Coverage: ${loc.radiusDisplay}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white54),
                          ),
                          trailing: isCurrent
                              ? Icon(Icons.check_circle,
                                  color: AdminColors.primaryGreen, size: 18)
                              : null,
                          onTap: () {
                            Navigator.of(ctx).pop();
                            viewModel.assignPOLocation(po, loc);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'PO ${po.poNumber} assigned to ${loc.name} Hub'),
                                backgroundColor: AdminColors.primaryGreen,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            if (po.locationId != null || po.locationName != null)
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  viewModel.assignPOLocation(po, null);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'PO ${po.poNumber} location cleared (Unassigned)'),
                      backgroundColor: Colors.grey[800],
                    ),
                  );
                },
                child: const Text('Clear Hub',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
          ],
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
