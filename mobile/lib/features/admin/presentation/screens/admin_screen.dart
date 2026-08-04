import 'package:mobile/l10n/app_localizations.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/widgets/app_scaffold.dart';
import 'package:mobile/features/admin/presentation/providers/admin_provider.dart';
import 'package:image_picker/image_picker.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Upload Dataset Form
  File? _uploadFile;
  String _uploadCropName = 'apple';
  String _customCropName = '';
  String _uploadDiseaseName = '';
  bool _isFullDataset = true;
  bool _uploadingDataset = false;

  // Start Training Form
  String _selectedDataset = 'apple';
  int _epochs = 15;
  bool _startingJob = false;

  // Send Notification Form
  String _notifTarget = 'all';
  final _notifTitleController = TextEditingController();
  final _notifMessageController = TextEditingController();
  bool _sendingNotif = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notifTitleController.dispose();
    _notifMessageController.dispose();
    super.dispose();
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  Future<void> _handleUploadDataset() async {
    if (_uploadFile == null) return _showError('Please select a zip file.');
    
    setState(() => _uploadingDataset = true);
    final finalCropName = _uploadCropName == 'others' ? _customCropName.toLowerCase().replaceAll(' ', '_') : _uploadCropName;
    
    if (!_isFullDataset && _uploadDiseaseName.isEmpty) {
      setState(() => _uploadingDataset = false);
      return _showError('Please enter the new disease name.');
    }

    try {
      await ref.read(adminProvider.notifier).uploadDataset(
        _uploadFile!, 
        finalCropName, 
        _isFullDataset, 
        !_isFullDataset ? _uploadDiseaseName : null
      );
      _showSuccess('Dataset uploaded successfully.');
      setState(() => _uploadFile = null);
    } catch (e) {
      _showError('Failed to upload dataset.');
    } finally {
      if (mounted) setState(() => _uploadingDataset = false);
    }
  }

  Future<void> _handleStartTraining() async {
    setState(() => _startingJob = true);
    try {
      await ref.read(adminProvider.notifier).startTraining(_selectedDataset, _epochs);
      _showSuccess('Farming model pipeline successfully triggered.');
    } catch (e) {
      _showError('Failed to start local training.');
    } finally {
      if (mounted) setState(() => _startingJob = false);
    }
  }

  Future<void> _handleSendNotification() async {
    setState(() => _sendingNotif = true);
    final targetUserId = _notifTarget == 'all' ? null : int.tryParse(_notifTarget);
    
    try {
      await ref.read(adminProvider.notifier).sendNotification(
        _notifTitleController.text, 
        _notifMessageController.text, 
        targetUserId
      );
      _showSuccess('Broadcasting alert successfully dispatched.');
      _notifTitleController.clear();
      _notifMessageController.clear();
    } catch (e) {
      _showError('Failed to broadcast alert.');
    } finally {
      if (mounted) setState(() => _sendingNotif = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final isLoading = state.isLoading;

    if (isLoading && state.jobs.isEmpty) {
      return AppScaffold(
        title: (AppLocalizations.of(context)?.superadminWorkspace ?? 'Super-Admin Workspace'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return AppScaffold(
      title: (AppLocalizations.of(context)?.superadminWorkspace ?? 'Super-Admin Workspace'),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: (AppLocalizations.of(context)?.aiModels ?? 'AI Models'), icon: const Icon(Icons.memory)),
              Tab(text: (AppLocalizations.of(context)?.users ?? 'Users'), icon: const Icon(Icons.people)),
              Tab(text: (AppLocalizations.of(context)?.tipsQueue ?? 'Tips Queue'), icon: const Icon(Icons.lightbulb)),
              Tab(text: (AppLocalizations.of(context)?.broadcast ?? 'Broadcast'), icon: const Icon(Icons.notifications)),
              Tab(text: (AppLocalizations.of(context)?.library ?? 'Library'), icon: const Icon(Icons.library_books)),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildModelsTab(state),
                _buildUsersTab(state),
                _buildTipsTab(state),
                _buildNotificationsTab(state),
                _buildLibraryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelsTab(AdminState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((AppLocalizations.of(context)?.uploadCustomAiDatasetZip ?? 'Upload Custom AI Dataset (ZIP)'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: (state.availableDatasets.contains(_uploadCropName) || _uploadCropName == 'others') 
                ? _uploadCropName 
                : (state.availableDatasets.isNotEmpty ? state.availableDatasets.first : 'others'),
            isExpanded: true,
            hint: Text((AppLocalizations.of(context)?.cropTarget ?? 'Crop Target')),
            items: [
              ...state.availableDatasets.map((crop) => DropdownMenuItem(value: crop, child: Text(crop.toUpperCase()))),
              DropdownMenuItem(value: 'others', child: Text((AppLocalizations.of(context)?.others ?? 'Others...'))),
            ],
            onChanged: (v) => setState(() => _uploadCropName = v!),
          ),
          if (_uploadCropName == 'others') ...[
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.newCropName ?? 'New Crop Name')),
              onChanged: (v) => setState(() => _customCropName = v),
            ),
          ],
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text((AppLocalizations.of(context)?.isFullDataset ?? 'Is Full Dataset?')),
            subtitle: Text((AppLocalizations.of(context)?.toggleOffForNewDiseaseClass ?? 'Toggle OFF for new disease class')),
            value: _isFullDataset,
            onChanged: (v) => setState(() => _isFullDataset = v),
          ),
          if (!_isFullDataset) ...[
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.newDiseaseFolderName ?? 'New Disease Folder Name')),
              onChanged: (v) => setState(() => _uploadDiseaseName = v),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final picker = ImagePicker();
              // ImagePicker doesn't support zip well, but we use XFile fallback or we assume file picker
              // In mobile, we actually need file_picker. But since we don't have file_picker in pubspec,
              // we can't actually pick ZIP files unless we add file_picker.
              _showError('ZIP upload is simulated here due to lack of file_picker dependency.');
            },
            icon: const Icon(Icons.attach_file),
            label: Text(_uploadFile != null ? 'File selected' : 'Select ZIP File'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _uploadingDataset ? null : _handleUploadDataset,
              child: _uploadingDataset ? const CircularProgressIndicator() : Text((AppLocalizations.of(context)?.uploadPrepareDataset ?? 'Upload & Prepare Dataset')),
            ),
          ),

          const Divider(height: 32),
          Text((AppLocalizations.of(context)?.initializeLocalDatasetTrainingJob ?? 'Initialize Local Dataset Training Job'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: state.availableDatasets.contains(_selectedDataset) ? _selectedDataset : null,
            isExpanded: true,
            hint: Text((AppLocalizations.of(context)?.selectDatasetCategory ?? 'Select Dataset Category')),
            items: state.availableDatasets.map((crop) => DropdownMenuItem(value: crop, child: Text(crop.toUpperCase()))).toList(),
            onChanged: (v) => setState(() => _selectedDataset = v!),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.epochCountIterations ?? 'Epoch Count (Iterations)')),
            keyboardType: TextInputType.number,
            onChanged: (v) => setState(() => _epochs = int.tryParse(v) ?? 15),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startingJob ? null : _handleStartTraining,
              child: _startingJob ? const CircularProgressIndicator() : Text((AppLocalizations.of(context)?.startTrainingPipeline ?? 'Start Training Pipeline')),
            ),
          ),

          const Divider(height: 32),
          Text((AppLocalizations.of(context)?.completedActiveModelCheckpoints ?? 'Completed & Active Model Checkpoints'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.jobs.length,
            itemBuilder: (context, index) {
              final job = state.jobs[index];
              return Card(
                child: ListTile(
                  title: Text('${job['dataset_name']} (Job #${job['id']})'),
                  subtitle: Text('Status: ${job['status']} | Acc: ${job['accuracy'] ?? '--'}'),
                  trailing: (job['status'] == 'completed' && !job['is_deployed'])
                      ? TextButton(
                          onPressed: () => ref.read(adminProvider.notifier).deployModel(job['id']),
                          child: Text((AppLocalizations.of(context)?.deploy ?? 'Deploy')),
                        )
                      : (job['is_deployed'] ? const Icon(Icons.check_circle, color: Colors.green) : null),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(AdminState state) {
    return ListView.builder(
      itemCount: state.users.length,
      itemBuilder: (context, index) {
        final user = state.users[index];
        return ListTile(
          title: Text(user.fullName ?? user.email),
          subtitle: Text('${user.email} | ${user.isAdmin ? 'Super-Admin' : 'Farmer'}'),
          trailing: Text(user.primaryCrop ?? ''),
        );
      },
    );
  }

  Widget _buildTipsTab(AdminState state) {
    if (state.pendingTips.isEmpty) return Center(child: Text((AppLocalizations.of(context)?.noPendingTips ?? 'No pending tips.')));
    return ListView.builder(
      itemCount: state.pendingTips.length,
      itemBuilder: (context, index) {
        final tip = state.pendingTips[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(tip.description),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => ref.read(adminProvider.notifier).deleteTip(tip.id),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: Text((AppLocalizations.of(context)?.reject ?? 'Reject'), style: const TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => ref.read(adminProvider.notifier).approveTip(tip.id),
                      icon: const Icon(Icons.check),
                      label: Text((AppLocalizations.of(context)?.approve ?? 'Approve')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationsTab(AdminState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((AppLocalizations.of(context)?.broadcastNotifications ?? 'Broadcast Notifications'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: _notifTarget,
            isExpanded: true,
            hint: Text((AppLocalizations.of(context)?.targetRecipients ?? 'Target Recipients')),
            items: [
              DropdownMenuItem(value: 'all', child: Text((AppLocalizations.of(context)?.allUsers ?? 'All Users'))),
              ...state.users.map((u) => DropdownMenuItem(value: u.id.toString(), child: Text(u.fullName ?? u.email))),
            ],
            onChanged: (v) => setState(() => _notifTarget = v!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notifTitleController,
            decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.alertHeadline ?? 'Alert Headline')),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notifMessageController,
            decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.detailedMessage ?? 'Detailed Message')),
            maxLines: 4,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendingNotif ? null : _handleSendNotification,
              icon: _sendingNotif ? const CircularProgressIndicator() : const Icon(Icons.send),
              label: Text((AppLocalizations.of(context)?.dispatchBroadcastAlert ?? 'Dispatch Broadcast Alert')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((AppLocalizations.of(context)?.diseaseLibraryManagement ?? 'Disease Library Management'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text((AppLocalizations.of(context)?.mockFormNoBackendApiIntegrationRequired ?? 'Mock form. No backend API integration required.'), style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          TextField(decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.cropType ?? 'Crop Type'))),
          const SizedBox(height: 16),
          TextField(decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.diseaseName ?? 'Disease Name'))),
          const SizedBox(height: 16),
          TextField(decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.scientificName ?? 'Scientific Name'))),
          const SizedBox(height: 16),
          TextField(decoration: InputDecoration(labelText: (AppLocalizations.of(context)?.overviewSymptoms ?? 'Overview / Symptoms')), maxLines: 3),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showSuccess('New disease successfully added to the global library database.'),
              child: Text((AppLocalizations.of(context)?.publishToDiseaseLibrary ?? 'Publish to Disease Library')),
            ),
          ),
        ],
      ),
    );
  }
}
