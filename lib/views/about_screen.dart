import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  final AppThemeMode currentTheme;

  // Project configuration values (derived directly from pubspec.yaml and main.dart)
  static const String appName = 'حاسبة احترافية';
  static const String appNameEnglish = 'Pro Calculator';
  static const String packageName = 'pro_calculator';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  static const String fullVersion = '$appVersion+$buildNumber';
  static const String developerName = 'م عمير العطاب';
  static const String developerTagline = 'تم التطوير بواسطة م عمير العطاب';

  const AboutScreen({
    super.key,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(currentTheme);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary),
            tooltip: 'رجوع',
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'حول التطبيق',
            style: GoogleFonts.cairo(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo & Header Section
                    _buildHeader(colors),

                    const SizedBox(height: 24),

                    // Developer Card (Prominently displaying the exact text required)
                    _buildDeveloperCard(colors),

                    const SizedBox(height: 20),

                    // App Features Overview
                    _buildFeaturesSection(colors),

                    const SizedBox(height: 20),

                    // Project Details & Version Information
                    _buildProjectDetails(colors),

                    const SizedBox(height: 28),

                    // Footer / Copyright
                    _buildFooter(colors),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors colors) {
    return Column(
      children: [
        // App Icon with soft ambient glow
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: colors.opBtnBg.withValues(alpha: 0.25),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: colors.accent.withValues(alpha: 0.2),
                blurRadius: 18,
                spreadRadius: -2,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Image.asset(
              'assets/icon/app_icon.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback icon container in case asset is loading
                return Container(
                  color: colors.surface,
                  child: Icon(
                    Icons.calculate_rounded,
                    size: 60,
                    color: colors.opBtnBg,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),

        // App Name
        Text(
          appName,
          style: GoogleFonts.cairo(
            color: colors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          appNameEnglish,
          style: GoogleFonts.cairo(
            color: colors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),

        // Version Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.accent.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tag_rounded,
                size: 14,
                color: colors.accent,
              ),
              const SizedBox(width: 6),
              Text(
                'الإصدار $appVersion ($buildNumber)',
                style: GoogleFonts.cairo(
                  color: colors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeveloperCard(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.opBtnBg.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.opBtnBg.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Developer Avatar / Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.opBtnBg,
                  colors.opBtnBg.withValues(alpha: 0.75),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors.opBtnBg.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.engineering_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Developer Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المطور',
                  style: GoogleFonts.cairo(
                    color: colors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  developerName,
                  style: GoogleFonts.cairo(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  developerTagline,
                  style: GoogleFonts.cairo(
                    color: colors.opBtnBg,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(AppColors colors) {
    final features = [
      (
        Icons.calculate_outlined,
        'حاسبة أساسية ذكية',
        'حسابات فورية مع معاينة حية للنتائج ودعم العمليات الحسابية المتتالية.',
        colors.accent,
      ),
      (
        Icons.functions_rounded,
        'حاسبة علمية متقدمة',
        'دوال مثلثية ولوغاريتمية وقوى وجذور مع دعم نظامي الدرجات والراديان (DEG / RAD).',
        colors.opBtnBg,
      ),
      (
        Icons.swap_horiz_rounded,
        'محول وحدات شامل',
        'تحويل دقيق بين وحدات الطول، الكتلة، المساحة، الحجم، ودرجات الحرارة.',
        colors.equalsBtnBg,
      ),
      (
        Icons.history_rounded,
        'سجل العمليات والتاريخ',
        'حفظ تلقائي لكافة العمليات الحسابية مع إمكانية استعادتها ومسحها بنقرة واحدة.',
        colors.accent,
      ),
      (
        Icons.palette_outlined,
        'مظاهر لونية عصرية',
        'خيارات متعددة تناسب كل الأذواق تشمل Cyber Dark، OLED الأسود، والنمط الفاتح.',
        colors.opBtnBg,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars_rounded, color: colors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'أبرز مميزات التطبيق',
                style: GoogleFonts.cairo(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...features.map((feat) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: feat.$4.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(feat.$1, size: 18, color: feat.$4),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feat.$2,
                            style: GoogleFonts.cairo(
                              color: colors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            feat.$3,
                            style: GoogleFonts.cairo(
                              color: colors.textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildProjectDetails(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.accent.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: colors.opBtnBg, size: 20),
              const SizedBox(width: 8),
              Text(
                'بيانات المشروع',
                style: GoogleFonts.cairo(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('اسم المشروع:', packageName, colors),
          _buildInfoRow('رقم الإصدار (Version):', appVersion, colors),
          _buildInfoRow('رقم البناء (Build Number):', buildNumber, colors),
          _buildInfoRow('إصدار التهيئة الكامل:', fullVersion, colors),
          _buildInfoRow('المطور المسؤول:', developerName, colors),
          _buildInfoRow('واجهة المستخدم:', 'Material 3 & Cairo Font', colors),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              color: colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value,
              style: GoogleFonts.cairo(
                color: colors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AppColors colors) {
    return Column(
      children: [
        Text(
          'جميع الحقوق محفوظة © ${DateTime.now().year}',
          style: GoogleFonts.cairo(
            color: colors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          developerTagline,
          style: GoogleFonts.cairo(
            color: colors.textSecondary.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
