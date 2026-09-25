import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';
import 'package:spare_shop_admin/ui/common/delivery_charge_models.dart';
import 'package:spare_shop_admin/ui/common/location_models.dart';
import 'package:spare_shop_admin/ui/views/admin_delivery_charges/admin_delivery_charges_viewmodel.dart';
import 'package:spare_shop_admin/ui/widgets/admin/admin_shell.dart';
import 'package:stacked/stacked.dart';

class AdminDeliveryChargesView
    extends StackedView<AdminDeliveryChargesViewModel> {
  const AdminDeliveryChargesView({Key? key}) : super(key: key);

  @override
  AdminDeliveryChargesViewModel viewModelBuilder(BuildContext context) =>
      AdminDeliveryChargesViewModel();

  @override
  Widget builder(
    BuildContext context,
    AdminDeliveryChargesViewModel viewModel,
    Widget? child,
  ) {
    return AdminShell(
      title: 'Delivery Charges & Tiers',
      selectedItem: AdminNavigationItem.deliveryCharges,
      child: viewModel.isBusy && viewModel.tiers.isEmpty
          ? Center(
              child: CircularProgressIndicator(color: AdminColors.primaryGreen),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, viewModel),
                const SizedBox(height: 20),
                _buildStatsGrid(context, viewModel),
                const SizedBox(height: 24),
                _buildLiveCalculator(context, viewModel),
                const SizedBox(height: 24),
                _buildTiersTableCard(context, viewModel),
              ],
            ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AdminDeliveryChargesViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        return Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment:
              isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Delivery Charges',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure tiered shipping rates based on customer order amounts & fulfillment hubs',
                  style: TextStyle(
                    fontSize: 14,
                    color: AdminColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (isMobile) const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(context, viewModel),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Add Delivery Tier',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid(
      BuildContext context, AdminDeliveryChargesViewModel viewModel) {
    final freeThreshold = viewModel.freeDeliveryThreshold;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 4
            : constraints.maxWidth > 550
                ? 2
                : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2,
          children: [
            _buildStatCard(
              title: 'Total Rate Tiers',
              value: '${viewModel.totalTiers}',
              subtitle: 'Active & Inactive rules',
              icon: Icons.local_shipping_outlined,
              color: Colors.blue,
            ),
            _buildStatCard(
              title: 'Active Rules',
              value: '${viewModel.activeTiers}',
              subtitle: 'Currently in checkout calculation',
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
            _buildStatCard(
              title: 'Free Delivery At',
              value: freeThreshold != null
                  ? '₹${freeThreshold.toInt()}+'
                  : 'Disabled',
              subtitle: freeThreshold != null
                  ? 'Zero delivery fee'
                  : 'No free tier configured',
              icon: Icons.card_giftcard,
              color: Colors.purple,
            ),
            _buildStatCard(
              title: 'Fulfillment Scope',
              value: viewModel.selectedLocationFilter == 'all'
                  ? 'Global (All)'
                  : 'Active Hub',
              subtitle: viewModel.selectedLocationFilter == 'all'
                  ? 'Applies to all warehouses'
                  : 'Filtered by active location',
              icon: Icons.storefront_outlined,
              color: Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCalculator(
      BuildContext context, AdminDeliveryChargesViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isColumn = constraints.maxWidth < 700;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AdminColors.primaryGreen.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.calculate_outlined,
                      color: AdminColors.accentLime,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Live Order Fee Tester & Simulator',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flex(
                direction: isColumn ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: isColumn
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: isColumn ? 0 : 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Test Order Subtotal (₹)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.15)),
                          ),
                          child: TextField(
                            controller: viewModel.testAmountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.currency_rupee,
                                  color: Colors.white70, size: 18),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              hintText: 'e.g. 350',
                              hintStyle: TextStyle(color: Colors.white38),
                            ),
                            onChanged: (_) => viewModel.calculateTestFee(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isColumn)
                    const SizedBox(height: 16)
                  else
                    const SizedBox(width: 24),
                  Expanded(
                    flex: isColumn ? 0 : 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AdminColors.primaryGreen.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CALCULATED DELIVERY FEE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: Colors.white60,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                viewModel.matchedTierText ??
                                    'Enter amount to calculate',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: viewModel.calculatedFee == 0
                                  ? Colors.green.withOpacity(0.2)
                                  : AdminColors.primaryGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: viewModel.calculatedFee == 0
                                    ? Colors.green
                                    : AdminColors.primaryGreen,
                              ),
                            ),
                            child: Text(
                              viewModel.calculatedFee == 0
                                  ? 'FREE'
                                  : '₹${(viewModel.calculatedFee ?? 0).toInt()}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: viewModel.calculatedFee == 0
                                    ? Colors.greenAccent
                                    : Colors.orangeAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTiersTableCard(
      BuildContext context, AdminDeliveryChargesViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by tier, amount or hub...',
                      prefixIcon: const Icon(Icons.search,
                          size: 20, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    onChanged: viewModel.setSearchQuery,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${viewModel.filteredTiers.length} Rules',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Tiers List
          if (viewModel.filteredTiers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.local_shipping_outlined,
                        size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'No Delivery Charge Tiers Found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Click "Add Delivery Tier" above to create your first rule.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewModel.filteredTiers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final tier = viewModel.filteredTiers[index];
                return _buildTierRow(context, viewModel, tier);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTierRow(BuildContext context,
      AdminDeliveryChargesViewModel viewModel, DeliveryChargeModel tier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Range Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AdminColors.primaryGreen.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AdminColors.primaryGreen.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_bag_outlined,
                    size: 16, color: AdminColors.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  tier.tierDisplay,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AdminColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Fee Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tier.isFreeDelivery
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: tier.isFreeDelivery
                    ? Colors.green.shade300
                    : Colors.orange.shade300,
              ),
            ),
            child: Text(
              tier.chargeDisplay,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: tier.isFreeDelivery
                    ? Colors.green.shade800
                    : Colors.orange.shade900,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Description & Hub
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.description ?? 'Standard delivery tier',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 13, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      tier.locationName ?? 'All Locations (HQ)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Switch
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: tier.isActive,
              activeTrackColor: AdminColors.primaryGreen,
              onChanged: (_) => viewModel.toggleStatus(tier),
            ),
          ),
          const SizedBox(width: 8),

          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
            tooltip: 'Edit Tier',
            onPressed: () =>
                _showAddEditDialog(context, viewModel, tierToEdit: tier),
          ),

          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            tooltip: 'Delete Tier',
            onPressed: () => _confirmDelete(context, viewModel, tier),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(
    BuildContext context,
    AdminDeliveryChargesViewModel viewModel, {
    DeliveryChargeModel? tierToEdit,
  }) {
    final isEdit = tierToEdit != null;
    final fromController = TextEditingController(
        text: isEdit ? tierToEdit.fromAmount.toInt().toString() : '0');
    final toController = TextEditingController(
        text: isEdit && tierToEdit.toAmount != null
            ? tierToEdit.toAmount!.toInt().toString()
            : '');
    final feeController = TextEditingController(
        text: isEdit ? tierToEdit.deliveryCharge.toInt().toString() : '60');
    final descController = TextEditingController(
        text: isEdit ? (tierToEdit.description ?? '') : '');

    bool isUnbounded = isEdit ? tierToEdit.toAmount == null : false;
    String selectedLocationId = isEdit
        ? (tierToEdit.locationId ?? 'all')
        : (viewModel.selectedLocationFilter != '__none__' &&
                viewModel.selectedLocationFilter != 'all'
            ? viewModel.selectedLocationFilter
            : 'all');
    bool isActive = isEdit ? tierToEdit.isActive : true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                isEdit
                    ? 'Edit Delivery Charge Tier'
                    : 'Add Delivery Charge Tier',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ORDER AMOUNT RANGE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: fromController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'From Amount (₹)',
                                prefixText: '₹ ',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: toController,
                              enabled: !isUnbounded,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: isUnbounded
                                    ? 'No Upper Limit'
                                    : 'To Amount (₹)',
                                prefixText: isUnbounded ? '' : '₹ ',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'No Upper Limit (₹ and above)',
                          style: TextStyle(fontSize: 13),
                        ),
                        value: isUnbounded,
                        activeColor: AdminColors.primaryGreen,
                        onChanged: (val) {
                          setState(() {
                            isUnbounded = val ?? false;
                            if (isUnbounded) {
                              toController.clear();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'DELIVERY CHARGE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: feeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Delivery Fee (₹) [Enter 0 for Free]',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'FULFILLMENT HUB SCOPE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedLocationId,
                        decoration: InputDecoration(
                          labelText: 'Applicable Hub',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'all',
                            child: Text('All Locations (Global / HQ)'),
                          ),
                          ...viewModel.locations.map(
                            (l) => DropdownMenuItem(
                              value: l.id,
                              child: Text(l.name),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedLocationId = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descController,
                        decoration: InputDecoration(
                          labelText: 'Description / Notes (Optional)',
                          hintText: 'e.g. Orders under ₹399 receive ₹60 fee',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final from =
                        double.tryParse(fromController.text.trim()) ?? 0.0;
                    final to = isUnbounded
                        ? null
                        : double.tryParse(toController.text.trim());
                    final charge =
                        double.tryParse(feeController.text.trim()) ?? 0.0;

                    String? locName = 'All Locations (HQ)';
                    if (selectedLocationId != 'all') {
                      final match = viewModel.locations
                          .where((l) => l.id == selectedLocationId);
                      if (match.isNotEmpty) {
                        locName = match.first.name;
                      }
                    }

                    Navigator.pop(dialogContext);

                    await viewModel.saveTier(
                      id: isEdit ? tierToEdit.id : null,
                      fromAmount: from,
                      toAmount: to,
                      deliveryCharge: charge,
                      locationId: selectedLocationId,
                      locationName: locName,
                      description: descController.text.trim().isNotEmpty
                          ? descController.text.trim()
                          : (to == null
                              ? 'Orders ₹${from.toInt()}+'
                              : 'Orders ₹${from.toInt()} - ₹${to.toInt()}'),
                      isActive: isActive,
                    );
                  },
                  child: Text(isEdit ? 'Save Changes' : 'Create Tier'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context,
      AdminDeliveryChargesViewModel viewModel, DeliveryChargeModel tier) {
    showDialog(
      context: context,
      builder: (dContext) => AlertDialog(
        title: const Text('Delete Delivery Tier?'),
        content: Text(
            'Are you sure you want to delete the rate rule "${tier.tierDisplay}" (${tier.chargeDisplay})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dContext);
              await viewModel.deleteTier(tier.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
