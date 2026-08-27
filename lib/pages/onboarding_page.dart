import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class OnboardingPreferences {
  OnboardingPreferences({
    this.intent,
    this.propertyTypes = const [],
    this.areas = const [],
    this.wantsToList = false,
  });

  final String? intent;
  final List<String> propertyTypes;
  final List<String> areas;
  final bool wantsToList;

  static const _doneKey = 'eh_onboarding_done';
  static const _intentKey = 'eh_pref_intent';
  static const _typesKey = 'eh_pref_types';
  static const _areasKey = 'eh_pref_areas';
  static const _listKey = 'eh_pref_wants_list';

  static Future<bool> isDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_doneKey) ?? false;
  }

  static Future<void> markDone(OnboardingPreferences prefsData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_doneKey, true);
    if (prefsData.intent != null) {
      await prefs.setString(_intentKey, prefsData.intent!);
    }
    await prefs.setStringList(_typesKey, prefsData.propertyTypes);
    await prefs.setStringList(_areasKey, prefsData.areas);
    await prefs.setBool(_listKey, prefsData.wantsToList);
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_doneKey);
  }
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    required this.onFinished,
  });

  /// Called when onboarding completes. [openRegister] is true when the user
  /// chose to create an owner account.
  final void Function({required bool openRegister}) onFinished;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _page = 0;

  String? _intent;
  final Set<String> _types = {};
  final Set<String> _areas = {};
  bool? _wantsToList;

  static const _intro = [
    (
      icon: Icons.search_rounded,
      title: 'Find homes across Rwanda',
      body:
          'Browse verified houses, apartments, and villas — for rent or sale — curated for real neighborhoods.',
    ),
    (
      icon: Icons.home_work_outlined,
      title: 'List your place with care',
      body:
          'Owners submit full details and photos. Every listing is reviewed by our team before it goes live.',
    ),
    (
      icon: Icons.verified_outlined,
      title: 'Trusted, not noisy',
      body:
          'No spam. No fake urgency. Just clear listings so you can decide with confidence.',
    ),
  ];

  void _next() {
    if (_page < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _finish({bool openAuth = false}) async {
    await OnboardingPreferences.markDone(
      OnboardingPreferences(
        intent: _intent,
        propertyTypes: _types.toList(),
        areas: _areas.toList(),
        wantsToList: _wantsToList == true,
      ),
    );
    widget.onFinished(openRegister: openAuth);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.brand500,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.home, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Easy Homes',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.brand700,
                    ),
                  ),
                  const Spacer(),
                  if (_page < 6)
                    TextButton(
                      onPressed: () => _finish(openAuth: false),
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  for (var i = 0; i < _intro.length; i++)
                    _IntroSlide(
                      icon: _intro[i].icon,
                      title: _intro[i].title,
                      body: _intro[i].body,
                      onContinue: _next,
                      cta: i == _intro.length - 1 ? 'Personalize my experience' : 'Next',
                    ),
                  _QuestionSlide(
                    title: 'What brings you here?',
                    subtitle: 'Tap one — we’ll tailor what you see.',
                    options: const [
                      ('rent', 'Looking to rent', Icons.key_outlined),
                      ('buy', 'Looking to buy', Icons.shopping_bag_outlined),
                      ('browse', 'Just browsing', Icons.explore_outlined),
                      ('list', 'I want to list a property', Icons.add_home_outlined),
                    ],
                    selected: _intent == null ? {} : {_intent!},
                    multi: false,
                    onToggle: (id) {
                      setState(() => _intent = id);
                      Future.delayed(const Duration(milliseconds: 180), _next);
                    },
                  ),
                  _QuestionSlide(
                    title: 'Which property types interest you?',
                    subtitle: 'Pick as many as you like.',
                    options: const [
                      ('house', 'House', Icons.house_outlined),
                      ('apartment', 'Apartment', Icons.apartment_outlined),
                      ('villa', 'Villa', Icons.villa_outlined),
                    ],
                    selected: _types,
                    multi: true,
                    onToggle: (id) {
                      setState(() {
                        if (_types.contains(id)) {
                          _types.remove(id);
                        } else {
                          _types.add(id);
                        }
                      });
                    },
                    onContinue: _types.isEmpty ? null : _next,
                    continueLabel: 'Continue',
                  ),
                  _QuestionSlide(
                    title: 'Where are you focusing?',
                    subtitle: 'Choose areas you care about most.',
                    options: const [
                      ('Gasabo', 'Gasabo', Icons.location_on_outlined),
                      ('Kicukiro', 'Kicukiro', Icons.location_on_outlined),
                      ('Nyarugenge', 'Nyarugenge', Icons.location_on_outlined),
                      ('Rubavu', 'Rubavu', Icons.location_on_outlined),
                      ('Muhanga', 'Muhanga', Icons.location_on_outlined),
                      ('anywhere', 'Anywhere in Rwanda', Icons.public_outlined),
                    ],
                    selected: _areas,
                    multi: true,
                    onToggle: (id) {
                      setState(() {
                        if (_areas.contains(id)) {
                          _areas.remove(id);
                        } else {
                          _areas.add(id);
                        }
                      });
                    },
                    onContinue: _areas.isEmpty ? null : _next,
                    continueLabel: 'Almost done',
                  ),
                  _FinalSlide(
                    wantsToList: _wantsToList,
                    onSelectList: (v) => setState(() => _wantsToList = v),
                    onBrowse: () => _finish(openAuth: false),
                    onCreateAccount: () => _finish(openAuth: true),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(7, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? AppColors.brand500 : AppColors.brand100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroSlide extends StatelessWidget {
  const _IntroSlide({
    required this.icon,
    required this.title,
    required this.body,
    required this.onContinue,
    required this.cta,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onContinue;
  final String cta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brand300, AppColors.brand700],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(cta),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionSlide extends StatelessWidget {
  const _QuestionSlide({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.multi,
    required this.onToggle,
    this.onContinue,
    this.continueLabel,
  });

  final String title;
  final String subtitle;
  final List<(String, String, IconData)> options;
  final Set<String> selected;
  final bool multi;
  final ValueChanged<String> onToggle;
  final VoidCallback? onContinue;
  final String? continueLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                for (final opt in options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OptionChip(
                      label: opt.$2,
                      icon: opt.$3,
                      selected: selected.contains(opt.$1),
                      onTap: () => onToggle(opt.$1),
                    ),
                  ),
              ],
            ),
          ),
          if (onContinue != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(continueLabel ?? 'Continue'),
              ),
            ),
        ],
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.brand50 : const Color(0xFFF8F9FB),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.brand400 : AppColors.stroke,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? AppColors.brand600 : Colors.grey[600],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.brand800 : Colors.black87,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: AppColors.brand500),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinalSlide extends StatelessWidget {
  const _FinalSlide({
    required this.wantsToList,
    required this.onSelectList,
    required this.onBrowse,
    required this.onCreateAccount,
  });

  final bool? wantsToList;
  final ValueChanged<bool> onSelectList;
  final VoidCallback onBrowse;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'One last thing',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Will you be listing a property with us?',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _OptionChip(
            label: 'Yes — help me get set up as an owner',
            icon: Icons.add_home_work_outlined,
            selected: wantsToList == true,
            onTap: () => onSelectList(true),
          ),
          const SizedBox(height: 10),
          _OptionChip(
            label: 'Not now — I just want to explore',
            icon: Icons.travel_explore_outlined,
            selected: wantsToList == false,
            onTap: () => onSelectList(false),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: wantsToList == null
                  ? null
                  : () {
                      if (wantsToList == true) {
                        onCreateAccount();
                      } else {
                        onBrowse();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand500,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.brand100,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                wantsToList == true ? 'Create my owner account' : 'Start exploring',
              ),
            ),
          ),
          if (wantsToList == true)
            TextButton(
              onPressed: onBrowse,
              child: const Text(
                'Maybe later — browse first',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
