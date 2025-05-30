import 'package:finance_management/data/model/help_faqs/help_faqs_model.dart';

class HelpFaqsRepository {
  static final List<HelpFaqsModel> _faqs = [
    // General
    HelpFaqsModel(
      title: 'How to use FinWise?',
      answer: 'Register an account and follow onboarding instructions.',
      type: 'General',
    ),
    HelpFaqsModel(
      title: 'How much does it cost to use FinWise?',
      answer:
          'FinWise is free for basic features. Premium features may require a subscription.',
      type: 'General',
    ),
    HelpFaqsModel(
      title: 'How to contact support?',
      answer:
          'Contact support via the Contact Us tab or email support@finwise.com.',
      type: 'General',
    ),
    HelpFaqsModel(
      title: 'Can I use the app offline?',
      answer:
          'Some features are available offline, but syncing requires internet.',
      type: 'General',
    ),
    HelpFaqsModel(
      title: 'Is FinWise available on iOS and Android?',
      answer: 'Yes, FinWise is available on both platforms.',
      type: 'General',
    ),
    HelpFaqsModel(
      title: 'How do I update the app?',
      answer: 'Update via the App Store or Google Play.',
      type: 'General',
    ),
    HelpFaqsModel(
      title: 'Can I use multiple devices?',
      answer: 'Yes, just log in with your account on any device.',
      type: 'General',
    ),
    HelpFaqsModel(
      title: 'How do I change the app language?',
      answer: 'Go to Settings > Language.',
      type: 'General',
    ),
    HelpFaqsModel(
      title: 'Does FinWise support dark mode?',
      answer: 'Yes, you can enable dark mode in Settings.',
      type: 'General',
    ),
    HelpFaqsModel(
      title: 'How do I enable notifications?',
      answer: 'Go to Settings > Notification Settings.',
      type: 'General',
    ),
    HelpFaqsModel(
      title: 'Can I export my data?',
      answer: 'Yes, export options are in Settings > Export Data.',
      type: 'General',
    ),
    HelpFaqsModel(
      title: 'How do I reset the app?',
      answer: 'Go to Settings > Reset App.',
      type: 'General',
    ),
    HelpFaqsModel(
      title: 'How do I invite friends?',
      answer: 'Use the Invite Friends feature in the app menu.',
      type: 'General',
    ),
    HelpFaqsModel(
      title: 'Is there a web version?',
      answer: 'Currently, FinWise is only available as a mobile app.',
      type: 'General',
    ),
    HelpFaqsModel(
      title: 'How do I give feedback?',
      answer: 'Send feedback via the Contact Us tab.',
      type: 'General',
    ),
    // Account
    HelpFaqsModel(
      title: 'How can I reset my password if I forget it?',
      answer: 'Use the Forgot Password feature on the login screen.',
      type: 'Account',
    ),
    HelpFaqsModel(
      title: 'How do I change my email address?',
      answer: 'Go to Profile > Edit Profile.',
      type: 'Account',
    ),
    HelpFaqsModel(
      title: 'How do I change my phone number?',
      answer: 'Go to Profile > Edit Profile.',
      type: 'Account',
    ),
    HelpFaqsModel(
      title: 'How do I delete my account?',
      answer: 'Go to Settings > Delete Account.',
      type: 'Account',
    ),
    HelpFaqsModel(
      title: 'How do I log out?',
      answer: 'Tap the Logout button in Profile.',
      type: 'Account',
    ),
    HelpFaqsModel(
      title: 'How do I change my password?',
      answer: 'Go to Settings > Password Settings.',
      type: 'Account',
    ),
    HelpFaqsModel(
      title: 'How do I update my profile picture?',
      answer: 'Tap your avatar in Profile to change it.',
      type: 'Account',
    ),
    HelpFaqsModel(
      title: 'How do I recover my account?',
      answer: 'Use the Forgot Password feature or contact support.',
      type: 'Account',
    ),
    HelpFaqsModel(
      title: 'Can I have multiple accounts?',
      answer: 'Each email can only register one account.',
      type: 'Account',
    ),
    HelpFaqsModel(
      title: 'How do I verify my email?',
      answer: 'A verification email is sent during registration.',
      type: 'Account',
    ),
    HelpFaqsModel(
      title: 'How do I change my username?',
      answer: 'Go to Profile > Edit Profile.',
      type: 'Account',
    ),
    HelpFaqsModel(
      title: 'How do I enable two-factor authentication?',
      answer: 'This feature is coming soon.',
      type: 'Account',
    ),
    HelpFaqsModel(
      title: 'How do I manage account privacy?',
      answer: 'Go to Settings > Privacy.',
      type: 'Account',
    ),
    HelpFaqsModel(
      title: 'How do I view my login history?',
      answer: 'Go to Profile > Account Activity.',
      type: 'Account',
    ),
    HelpFaqsModel(
      title: 'How do I link my account to social media?',
      answer: 'Go to Settings > Linked Accounts.',
      type: 'Account',
    ),
    HelpFaqsModel(
      title: 'How do I change my notification preferences?',
      answer: 'Go to Settings > Notification Settings.',
      type: 'Account',
    ),
    // Services
    HelpFaqsModel(
      title: 'Can I customize settings within the application?',
      answer: 'Yes, you can customize various settings in the Settings menu.',
      type: 'Services',
    ),
    HelpFaqsModel(
      title: 'How do I access my expense history?',
      answer: 'Navigate to the Transactions tab.',
      type: 'Services',
    ),
    HelpFaqsModel(
      title: 'How do I add a new transaction?',
      answer: 'Tap the + button on the home screen.',
      type: 'Services',
    ),
    HelpFaqsModel(
      title: 'How do I set a budget?',
      answer: 'Go to Analysis > Budgets.',
      type: 'Services',
    ),
    HelpFaqsModel(
      title: 'How do I get spending reports?',
      answer: 'Go to Analysis > Reports.',
      type: 'Services',
    ),
    HelpFaqsModel(
      title: 'How do I categorize expenses?',
      answer: 'When adding a transaction, select a category.',
      type: 'Services',
    ),
    HelpFaqsModel(
      title: 'How do I set reminders?',
      answer: 'Go to Settings > Reminders.',
      type: 'Services',
    ),
    HelpFaqsModel(
      title: 'How do I use recurring transactions?',
      answer: 'Enable recurring when adding a transaction.',
      type: 'Services',
    ),
    HelpFaqsModel(
      title: 'How do I backup my data?',
      answer: 'Go to Settings > Backup.',
      type: 'Services',
    ),
    HelpFaqsModel(
      title: 'How do I restore data?',
      answer: 'Go to Settings > Restore.',
      type: 'Services',
    ),
    HelpFaqsModel(
      title: 'How do I use the calendar view?',
      answer: 'Go to Transactions > Calendar.',
      type: 'Services',
    ),
    HelpFaqsModel(
      title: 'How do I split a bill?',
      answer: 'Use the Split Bill feature in Transactions.',
      type: 'Services',
    ),
    HelpFaqsModel(
      title: 'How do I add notes to transactions?',
      answer: 'There is a notes field when adding/editing a transaction.',
      type: 'Services',
    ),
    HelpFaqsModel(
      title: 'How do I set up notifications for bills?',
      answer: 'Go to Settings > Notification Settings.',
      type: 'Services',
    ),
    HelpFaqsModel(
      title: 'How do I use currency conversion?',
      answer: 'Go to Settings > Currency.',
      type: 'Services',
    ),
    HelpFaqsModel(
      title: 'How do I manage subscriptions?',
      answer: 'Go to Analysis > Subscriptions.',
      type: 'Services',
    ),
    HelpFaqsModel(
      title: 'How do I use the search feature?',
      answer:
          'Use the search bar at the top of the Transactions or Categories screen.',
      type: 'Services',
    ),
  ];

  List<HelpFaqsModel> getFaqsByType(String type) {
    return _faqs.where((faq) => faq.type == type).toList();
  }

  List<HelpFaqsModel> searchFaqs(String query) {
    return _faqs
        .where((faq) => faq.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<HelpFaqsModel> getAllFaqs() => _faqs;
}
