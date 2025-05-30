import 'package:flutter/material.dart';
import 'package:finance_management/data/model/help_faqs/help_faqs_model.dart';
import 'package:finance_management/data/repositories/help_faqs_repository.dart';
import 'package:finance_management/presentation/widgets/widget/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_main/profile_screen.dart';
import 'package:finance_management/presentation/screens/authentication/profile/profile_help/profile_online_support_ai_lobby.dart';

class ProfileHelpFaqsScreen extends StatefulWidget {
  static const String routeName = '/profile-help-faqs';
  const ProfileHelpFaqsScreen({super.key});

  @override
  State<ProfileHelpFaqsScreen> createState() => _ProfileHelpFaqsScreenState();
}

class _ProfileHelpFaqsScreenState extends State<ProfileHelpFaqsScreen> {
  final HelpFaqsRepository _repo = HelpFaqsRepository();
  String _tab = 'FAQ';
  String _category = 'General';
  String _search = '';
  int _expandedIndex = -1;
  String? _snackBarMessage;

  @override
  Widget build(BuildContext context) {
    final faqs =
        _search.isEmpty
            ? _repo.getFaqsByType(_category)
            : _repo
                .searchFaqs(_search)
                .where((e) => e.type == _category)
                .toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_snackBarMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_snackBarMessage!)));
        setState(() {
          _snackBarMessage = null;
        });
      }
    });
    return Scaffold(
      backgroundColor: AppColors.caribbeanGreen,
      body: Container(
        color: AppColors.caribbeanGreen,
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 24,
                  left: 8,
                  right: 24,
                  bottom: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.go(ProfileScreen.routeName),
                    ),
                    const Text(
                      'Help & FAQS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.notifications_none,
                          color: Colors.black,
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.honeydew,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'How Can We Help You?',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackHeader,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [_buildTab('FAQ'), _buildTab('Contact Us')],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _buildCategory('General'),
                          _buildCategory('Account'),
                          _buildCategory('Services'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.caribbeanGreen,
                            width: 1.2,
                          ),
                          color: const Color(0xFFD6F5E6),
                        ),
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                          ),
                          onChanged: (v) => setState(() => _search = v),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child:
                            _tab == 'FAQ'
                                ? _buildFaqList(faqs)
                                : _buildContactList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label) {
    final selected = _tab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = label),
        child: Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color:
                selected ? AppColors.caribbeanGreen : const Color(0xFFD6F5E6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  selected ? AppColors.caribbeanGreen : const Color(0xFFD6F5E6),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.blackHeader,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(String label) {
    final selected = _category == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onCategoryChanged(label),
        child: Container(
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color:
                selected ? AppColors.caribbeanGreen : const Color(0xFFD6F5E6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  selected ? AppColors.caribbeanGreen : const Color(0xFFD6F5E6),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.blackHeader,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqList(List<HelpFaqsModel> faqs) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: faqs.length,
      itemBuilder: (context, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            color: AppColors.honeydew,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE8F6EA)),
          ),
          child: ExpansionTile(
            key: Key('faq_${_category}_$i'),
            initiallyExpanded: _expandedIndex == i,
            onExpansionChanged: (expanded) {
              setState(() {
                _expandedIndex = expanded ? i : -1;
              });
            },
            title: Text(
              faqs[i].title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.blackHeader,
              ),
            ),
            trailing: const Icon(Icons.expand_more, color: Colors.black),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
                child: Text(
                  faqs[i].answer,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.blackHeader,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactList() {
    final contacts = [
      {'icon': Icons.support_agent, 'label': 'Customer Service'},
      {'icon': Icons.language, 'label': 'Website'},
      {'icon': Icons.facebook, 'label': 'Facebook'},
      {'icon': Icons.chat, 'label': 'Whatsapp'},
      {'icon': Icons.camera_alt, 'label': 'Instagram'},
    ];
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: contacts.length,
      itemBuilder: (context, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE8F6EA)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color.fromARGB(
                255,
                255,
                255,
                255,
              ).withValues(alpha: (0.15 * 255).round().toDouble()),
              child: Icon(
                contacts[i]['icon'] as IconData,
                color: AppColors.caribbeanGreen,
              ),
            ),
            title: Text(
              contacts[i]['label'] as String,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.blackHeader,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () async {
              final url = contacts[i]['url'];
              if (contacts[i]['label'] == 'Customer Service') {
                context.push(ProfileOnlineSupportAiLobbyScreen.routeName);
                return;
              }
              if (url != null && url is String && url.isNotEmpty) {
                final uri = Uri.parse(url);
                try {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    setState(() {
                      _snackBarMessage = 'Could not launch the link!';
                    });
                  }
                } catch (e) {
                  setState(() {
                    _snackBarMessage = 'Error: $e';
                  });
                }
              }
            },
          ),
        );
      },
    );
  }

  void _onCategoryChanged(String label) {
    setState(() {
      _category = label;
      _expandedIndex = -1;
    });
  }
}
