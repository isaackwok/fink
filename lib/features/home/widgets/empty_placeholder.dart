import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movie_journal/features/search_movie/screens/search_movie.dart';
import 'package:movie_journal/l10n/app_localizations.dart';

class EmptyPlaceholder extends StatelessWidget {
  const EmptyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Column(
            children: [
              SizedBox(height: constraints.maxHeight * 0.15),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 10),
                  ],
                ),
                child: SvgPicture.asset(
                  'assets/images/empty_placeholder.svg',
                  width: 180,
                ),
              ),
              const SizedBox(height: 36),
              Text(
                l10n.homeEmptyTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'AvenirNext',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 288,
                child: Text(
                  l10n.homeEmptyBody,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'AvenirNext',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overlayColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Colors.transparent,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchMovieScreen(),
                    ),
                  );
                },
                child: Text(
                  l10n.addJournal,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'AvenirNext',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
