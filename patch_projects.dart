        const CreditBadge(),
        const SizedBox(width: 8),
        const ProButton(),
      ],
    );
  }
}

class CreditBadge extends ConsumerWidget {
  const CreditBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credits = ref.watch(creditsProvider);
    final isTestMode = ref.watch(testModeProvider);
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.electric_bolt_rounded,
            color: Color(0xFFFFC107),
            size: 19,
          ),
          const SizedBox(width: 5),
          if (isTestMode)
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.all_inclusive_rounded,
                color: Colors.white,
                size: 18,
              ),
            )
          else
            Text(
              '$credits',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
        ],
      ),
    );
  }
}
