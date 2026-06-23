import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/feature_icon.dart';

class PromoPage extends StatelessWidget {
  const PromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final promos = [
      {
        't': 'Cashback 30% di Kantin Kampus',
        'd': 'Maks. Rp10.000 · s.d. 30 Jun',
        'tone': 'red',
        'icon': Icons.restaurant_outlined
      },
      {
        't': 'Gratis biaya transfer antarbank',
        'd': 'Setiap Jumat · semua bank',
        'tone': 'green',
        'icon': Icons.send_rounded
      },
      {
        't': 'Diskon UKT 0% cicilan 6 bulan',
        'd': 'Khusus pengguna baru',
        'tone': 'violet',
        'icon': Icons.receipt_long_outlined
      },
      {
        't': 'Bonus 5.000 poin top up pertama',
        'd': 'Min. Rp50.000',
        'tone': 'amber',
        'icon': Icons.star_outline_rounded
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 12, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Promo & Reward',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: 0,
                    )),
                Divider(height: 18, color: AppColors.line2),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppBadge(label: 'SPESIAL MAHASISWA', tone: 'amber'),
                      SizedBox(height: 12),
                      Text('Bayar kuliah,\ndapat cashback',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          )),
                      SizedBox(height: 8),
                      Text('Kumpulkan poin tiap transaksi.',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13.5,
                            color: Color(0xFFBEBEBE),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ...promos.map((p) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.line, width: 1),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          FeatureIcon(
                              icon: p['icon'] as IconData,
                              tone: p['tone'] as String,
                              size: 44,
                              iconSize: 22),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['t'] as String,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.ink,
                                      height: 1.3,
                                    )),
                                const SizedBox(height: 3),
                                Text(p['d'] as String,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12.5,
                                      color: AppColors.slate400,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
