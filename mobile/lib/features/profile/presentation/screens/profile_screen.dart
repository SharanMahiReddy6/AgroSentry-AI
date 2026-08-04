import 'package:mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/widgets/app_scaffold.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/profile/presentation/providers/profile_provider.dart';
import 'package:mobile/core/env/env.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

const List<String> _states = [
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
  'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand',
  'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur',
  'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
  'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana', 'Tripura',
  'Uttar Pradesh', 'Uttarakhand', 'West Bengal', 'Delhi',
  'Jammu & Kashmir', 'Ladakh', 'Puducherry', 'Chandigarh',
  'Andaman & Nicobar Islands', 'Dadra & Nagar Haveli and Daman & Diu', 'Lakshadweep',
];

const Map<String, List<String>> _cities = {
  'Andhra Pradesh': ['Visakhapatnam','Vijayawada','Guntur','Nellore','Kurnool','Rajahmundry','Tirupati','Kakinada','Kadapa','Anantapur'],
  'Arunachal Pradesh': ['Itanagar','Naharlagun','Pasighat','Tawang','Ziro'],
  'Assam': ['Guwahati','Silchar','Dibrugarh','Jorhat','Nagaon','Tinsukia','Tezpur'],
  'Bihar': ['Patna','Gaya','Bhagalpur','Muzaffarpur','Purnia','Darbhanga','Arrah'],
  'Chhattisgarh': ['Raipur','Bhilai','Bilaspur','Korba','Rajnandgaon','Jagdalpur'],
  'Goa': ['Panaji','Margao','Vasco da Gama','Mapusa','Ponda'],
  'Gujarat': ['Ahmedabad','Surat','Vadodara','Rajkot','Bhavnagar','Jamnagar','Gandhinagar'],
  'Haryana': ['Faridabad','Gurgaon','Panipat','Ambala','Hisar','Rohtak','Karnal'],
  'Himachal Pradesh': ['Shimla','Manali','Dharamshala','Solan','Mandi','Kullu'],
  'Jharkhand': ['Ranchi','Jamshedpur','Dhanbad','Bokaro','Hazaribagh','Giridih'],
  'Karnataka': ['Bengaluru','Mysuru','Hubballi','Mangaluru','Belagavi','Davanagere','Ballari','Vijayapura'],
  'Kerala': ['Thiruvananthapuram','Kochi','Kozhikode','Thrissur','Kollam','Palakkad','Alappuzha','Malappuram'],
  'Madhya Pradesh': ['Bhopal','Indore','Jabalpur','Gwalior','Ujjain','Rewa','Satna'],
  'Maharashtra': ['Mumbai','Pune','Nagpur','Nashik','Aurangabad','Solapur','Amravati','Kolhapur'],
  'Manipur': ['Imphal','Thoubal','Bishnupur','Churachandpur'],
  'Meghalaya': ['Shillong','Tura','Nongstoin','Jowai'],
  'Mizoram': ['Aizawl','Lunglei','Champhai','Serchhip'],
  'Nagaland': ['Kohima','Dimapur','Mokokchung','Wokha'],
  'Odisha': ['Bhubaneswar','Cuttack','Rourkela','Brahmapur','Sambalpur','Puri','Balasore'],
  'Punjab': ['Ludhiana','Amritsar','Jalandhar','Patiala','Bathinda','Mohali','Gurdaspur'],
  'Rajasthan': ['Jaipur','Jodhpur','Udaipur','Kota','Ajmer','Bikaner','Alwar'],
  'Sikkim': ['Gangtok','Namchi','Gyalshing','Mangan'],
  'Tamil Nadu': ['Chennai','Coimbatore','Madurai','Tiruchirappalli','Salem','Tirunelveli','Erode','Vellore','Tiruppur'],
  'Telangana': ['Hyderabad','Warangal','Nizamabad','Karimnagar','Ramagundam','Khammam','Mancherial'],
  'Tripura': ['Agartala','Udaipur','Dharmanagar','Sabroom'],
  'Uttar Pradesh': ['Lucknow','Kanpur','Ghaziabad','Agra','Meerut','Varanasi','Allahabad','Bareilly','Aligarh'],
  'Uttarakhand': ['Dehradun','Haridwar','Roorkee','Haldwani','Rudrapur','Kashipur'],
  'West Bengal': ['Kolkata','Asansol','Siliguri','Durgapur','Bardhaman','Malda','Howrah'],
  'Delhi': ['New Delhi','Dwarka','Rohini','Saket','Janakpuri','Laxmi Nagar'],
  'Jammu & Kashmir': ['Srinagar','Jammu','Anantnag','Baramulla','Sopore'],
  'Ladakh': ['Leh','Kargil'],
  'Puducherry': ['Puducherry','Karaikal','Mahe','Yanam'],
  'Chandigarh': ['Chandigarh'],
  'Andaman & Nicobar Islands': ['Port Blair'],
  'Dadra & Nagar Haveli and Daman & Diu': ['Daman','Diu','Silvassa'],
  'Lakshadweep': ['Kavaratti'],
};

const List<String> _crops = ['Apple','Blueberry','Cherry','Corn','Grape','Orange','Peach','Pepper','Potato'];

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  String? _selectedState;
  String? _selectedCity;
  String? _selectedCrop = 'Apple';

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showOldPassword = false;
  bool _showNewPassword = false;

  String _selectedTheme = 'light';
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user.fullName ?? '';
      _usernameController.text = user.username ?? '';
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      
      setState(() {
        _selectedState = _states.contains(user.region) ? user.region : null;
        
        if (_selectedState != null && _cities[_selectedState!] != null && _cities[_selectedState!]!.contains(user.location)) {
          _selectedCity = user.location;
        } else {
          _selectedCity = null;
        }
        
        String matchedCrop = 'Apple';
        if (user.primaryCrop != null) {
          try {
            matchedCrop = _crops.firstWhere((c) => c.toLowerCase() == user.primaryCrop!.toLowerCase());
          } catch (_) {
            matchedCrop = 'Apple';
          }
        }
        _selectedCrop = matchedCrop;
        
        _selectedTheme = user.theme ?? 'light';
        _selectedLanguage = user.language ?? 'en';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSavePersonal() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    
    // We send back the exact properties as the web app
    final payload = {
      'full_name': _nameController.text,
      'username': _usernameController.text,
      'phone_number': _phoneController.text,
      'region': _selectedState,
      'location': _selectedCity,
      'primary_crop': _selectedCrop,
      'theme': user.theme ?? 'light',
      'language': user.language ?? 'en',
      'email_notifications': user.emailNotifications ?? true,
      'push_notifications': user.pushNotifications ?? true,
      'privacy_share_data': user.privacyShareData ?? true,
      'two_factor_enabled': user.twoFactorEnabled ?? false,
    };

    try {
      await ref.read(profileProvider.notifier).updateProfile(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((AppLocalizations.of(context)?.profileSavedSuccessfully ?? 'Profile saved successfully.'))));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((AppLocalizations.of(context)?.failedToSaveProfile ?? 'Failed to save profile.'))));
      }
    }
  }

  Future<void> _handleSavePreferences() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    
    final payload = {
      'full_name': user.fullName,
      'username': user.username,
      'phone_number': user.phoneNumber,
      'region': user.region,
      'location': user.location,
      'primary_crop': user.primaryCrop,
      'theme': _selectedTheme,
      'language': _selectedLanguage,
      'email_notifications': user.emailNotifications ?? true,
      'push_notifications': user.pushNotifications ?? true,
      'privacy_share_data': user.privacyShareData ?? true,
      'two_factor_enabled': user.twoFactorEnabled ?? false,
    };

    try {
      await ref.read(profileProvider.notifier).updateProfile(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((AppLocalizations.of(context)?.preferencesSavedSuccessfully ?? 'Preferences saved successfully.'))));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((AppLocalizations.of(context)?.failedToSavePreferences ?? 'Failed to save preferences.'))));
      }
    }
  }

  Future<void> _handleChangePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((AppLocalizations.of(context)?.newPasswordsDoNotMatch ?? 'New passwords do not match.'))));
      return;
    }
    
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((AppLocalizations.of(context)?.passwordMustBeAtLeast6Characters ?? 'Password must be at least 6 characters.'))));
      return;
    }

    try {
      await ref.read(profileProvider.notifier).changePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((AppLocalizations.of(context)?.passwordChangedSuccessfully ?? 'Password changed successfully.'))));
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((AppLocalizations.of(context)?.failedToChangePassword ?? 'Failed to change password.'))));
      }
    }
  }

  Future<void> _handlePickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      try {
        await ref.read(profileProvider.notifier).uploadPhoto(File(image.path));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((AppLocalizations.of(context)?.photoUpdated ?? 'Photo updated.'))));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((AppLocalizations.of(context)?.failedToUpdatePhoto ?? 'Failed to update photo.'))));
        }
      }
    }
  }

  Future<void> _handleRemoveImage() async {
    try {
      await ref.read(profileProvider.notifier).deletePhoto();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((AppLocalizations.of(context)?.photoRemoved ?? 'Photo removed.'))));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((AppLocalizations.of(context)?.failedToRemovePhoto ?? 'Failed to remove photo.'))));
      }
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length > 1 ? 2 : 1).toUpperCase();
  }

  String _buildPhotoUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    String cleanPath = path;
    if (cleanPath.startsWith('file://')) {
      cleanPath = cleanPath.replaceFirst('file://', '');
    }
    if (!cleanPath.startsWith('/')) cleanPath = '/$cleanPath';
    final base = Env.apiBaseUrl.replaceAll(RegExp(r'/api/?$'), '');
    return '$base$cleanPath';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final profileState = ref.watch(profileProvider);
    final isLoading = profileState is AsyncLoading;

    if (user == null) {
      return AppScaffold(
        title: (AppLocalizations.of(context)?.accountSettings ?? 'Account Settings'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final String photoUrl = _buildPhotoUrl(user.profilePhoto);
    final String formattedDate = user.createdAt != null ? user.createdAt!.split('T')[0] : '';

    return AppScaffold(
      title: (AppLocalizations.of(context)?.accountSettings ?? 'Account Settings'),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                        child: photoUrl.isEmpty ? Text(
                          _getInitials(user.fullName),
                          style: TextStyle(
                            fontSize: 32,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ) : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: isLoading ? null : _handlePickImage,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName?.isNotEmpty == true ? user.fullName! : 'Your Name',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    (user.isAdmin) ? 'ADMINISTRATOR' : 'PREMIUM FARMER',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (user.profilePhoto != null)
                    TextButton.icon(
                      onPressed: isLoading ? null : _handleRemoveImage,
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      label: Text((AppLocalizations.of(context)?.removePhoto ?? 'Remove photo'), style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  if (formattedDate.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Member since $formattedDate',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: [
                  Tab(icon: const Icon(Icons.person), text: (AppLocalizations.of(context)?.personal ?? 'Personal')),
                  Tab(icon: const Icon(Icons.security), text: (AppLocalizations.of(context)?.security ?? 'Security')),
                  Tab(icon: const Icon(Icons.language), text: (AppLocalizations.of(context)?.preferences ?? 'Preferences')),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPersonalInfoTab(isLoading),
                _buildSecurityTab(isLoading),
                _buildPreferencesTab(isLoading),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab(bool isLoading) {
    List<String> currentCities = _selectedState != null ? _cities[_selectedState] ?? [] : [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((AppLocalizations.of(context)?.personalInformation ?? 'Personal Information'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text((AppLocalizations.of(context)?.updateYourNameContactDetailsAndFarmingPr ?? 'Update your name, contact details, and farming profile.'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),
          
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.fullName ?? 'Full Name'), prefixIcon: const Icon(Icons.person_outline)),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.username ?? 'Username'), prefixIcon: const Icon(Icons.alternate_email)),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _emailController,
            enabled: false, // Read only
            decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.emailAddress ?? 'Email Address'), prefixIcon: const Icon(Icons.email_outlined)),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.phoneNumber ?? 'Phone Number'), prefixIcon: const Icon(Icons.phone_outlined)),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            initialValue: _selectedState,
            decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.farmingRegionState ?? 'Farming Region (State)'), prefixIcon: const Icon(Icons.map_outlined)),
            items: _states.map((state) => DropdownMenuItem(value: state, child: Text(state))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedState = val;
                _selectedCity = null;
              });
            },
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            initialValue: _selectedCity,
            decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.locationCity ?? 'Location / City'), prefixIcon: const Icon(Icons.location_city_outlined)),
            items: currentCities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
            onChanged: _selectedState == null ? null : (val) {
              setState(() {
                _selectedCity = val;
              });
            },
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            initialValue: _selectedCrop,
            decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.primaryCrop ?? 'Primary Crop'), prefixIcon: const Icon(Icons.grass_outlined)),
            items: _crops.map((crop) => DropdownMenuItem(value: crop, child: Text(crop))).toList(),
            onChanged: (val) {
              setState(() {
                _selectedCrop = val;
              });
            },
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _handleSavePersonal,
              icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
              label: Text((AppLocalizations.of(context)?.saveChanges ?? 'Save Changes')),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSecurityTab(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((AppLocalizations.of(context)?.changePassword ?? 'Change Password'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text((AppLocalizations.of(context)?.useAStrongUniquePasswordToProtectYourAcc ?? 'Use a strong, unique password to protect your account.'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),
          
          TextField(
            controller: _oldPasswordController,
            obscureText: !_showOldPassword,
            decoration: InputDecoration(
              labelText: (AppLocalizations.of(context)?.currentPassword ?? 'Current Password'),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_showOldPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _showOldPassword = !_showOldPassword),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _newPasswordController,
            obscureText: !_showNewPassword,
            decoration: InputDecoration(
              labelText: (AppLocalizations.of(context)?.newPassword ?? 'New Password'),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_showNewPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _confirmPasswordController,
            obscureText: !_showNewPassword, // Same toggle for confirm
            decoration: InputDecoration(
              labelText: (AppLocalizations.of(context)?.confirmNewPassword ?? 'Confirm New Password'),
              prefixIcon: const Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _handleChangePassword,
              icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.shield),
              label: Text((AppLocalizations.of(context)?.updatePassword ?? 'Update Password')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((AppLocalizations.of(context)?.appPreferences ?? 'App Preferences'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text((AppLocalizations.of(context)?.chooseYourDisplayThemeAndLanguageSetting ?? 'Choose your display theme and language settings.'), style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),
          
          Text((AppLocalizations.of(context)?.interfaceTheme ?? 'INTERFACE THEME'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _ThemeCard(
                  title: (AppLocalizations.of(context)?.lightMode ?? 'Light Mode'),
                  desc: 'Clean white interface',
                  icon: Icons.light_mode,
                  isSelected: _selectedTheme == 'light',
                  onTap: () => setState(() => _selectedTheme = 'light'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ThemeCard(
                  title: (AppLocalizations.of(context)?.darkMode ?? 'Dark Mode'),
                  desc: 'Easier on the eyes',
                  icon: Icons.dark_mode,
                  isSelected: _selectedTheme == 'dark',
                  onTap: () => setState(() => _selectedTheme = 'dark'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          Text((AppLocalizations.of(context)?.language ?? 'LANGUAGE'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            initialValue: _selectedLanguage,
            decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.selectLanguage ?? 'Select Language'), prefixIcon: const Icon(Icons.language)),
            items: [
              DropdownMenuItem(value: 'en', child: Text((AppLocalizations.of(context)?.englishDefault ?? 'English (Default)'))),
              DropdownMenuItem(value: 'te', child: Text((AppLocalizations.of(context)?.telugu ?? 'తెలుగు (Telugu)'))),
              DropdownMenuItem(value: 'hi', child: Text((AppLocalizations.of(context)?.hindi ?? 'हिन्दी (Hindi)'))),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedLanguage = val);
              }
            },
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _handleSavePreferences,
              icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
              label: Text((AppLocalizations.of(context)?.savePreferences ?? 'Save Preferences')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.05) : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
