part of '../account_profile_pages.dart';

class AccountProfileEditPage extends StatefulWidget {
  const AccountProfileEditPage({
    super.key,
    required this.api,
    required this.profile,
  });

  final ZhihuApiClient api;
  final Map<String, dynamic> profile;

  @override
  State<AccountProfileEditPage> createState() => _AccountProfileEditPageState();
}

class _AccountProfileEditPageState extends State<AccountProfileEditPage> {
  late String _name;
  late String _headline;
  late String _description;
  late String _gender;
  late String _birthday;
  late String _location;
  late String _business;
  late List<Map<String, Object?>> _educations;
  late List<Map<String, Object?>> _employments;
  late final Map<String, String> _originalBasic;
  late final String _originalAdvanced;
  var _saving = false;
  String? _uploadingImage;

  @override
  void initState() {
    super.initState();
    _name = plainText(widget.profile['name']);
    _headline = plainText(widget.profile['headline']);
    _description = plainText(widget.profile['description']);
    _gender = _profileGender(widget.profile);
    _birthday = profileBirthdayText(widget.profile);
    _location = _profileLocation(widget.profile);
    _business = _profileBusiness(widget.profile);
    _educations = _educationPayload(widget.profile['educations']);
    _employments = _employmentPayload(widget.profile['employments']);
    _originalBasic = _basicFields();
    _originalAdvanced = jsonEncode(_advancedFields());
  }

  Map<String, String> _basicFields() => <String, String>{
    'name': _name.trim(),
    'headline': _headline.trim(),
    'description': _description.trim(),
    'birthday': _birthday.isEmpty
        ? ''
        : jsonEncode({
            'year': int.parse(_birthday.substring(0, 4)),
            'month': int.parse(_birthday.substring(5, 7)),
            'day': int.parse(_birthday.substring(8, 10)),
          }),
    'gender': _gender == 'female'
        ? '0'
        : _gender == 'male'
        ? '1'
        : '-1',
    'business': _business.trim(),
  };

  Map<String, Object?> _advancedFields() => <String, Object?>{
    'educations': _educations,
    'employments': _employments,
    'locations': _location.trim().isEmpty
        ? <Map<String, Object?>>[]
        : <Map<String, Object?>>[
            {'address': _location.trim()},
          ],
  };

  List<Map<String, Object?>> _educationPayload(Object? value) => [
    for (final item in _profileMaps(value))
      {
        'school': _profileObjectName(item['school']),
        'major': _profileObjectName(item['major']),
        'entrance_year': plainText(item['entrance_year']),
        'graduation_year': plainText(item['graduation_year']),
        'diploma': plainText(item['diploma']),
      },
  ];

  List<Map<String, Object?>> _employmentPayload(Object? value) => [
    for (final item in _profileMaps(value))
      {
        'company': _profileObjectName(item['company']),
        'job': _profileObjectName(item['job']),
      },
  ];

  Future<void> _save() async {
    if (_saving) return;
    final l10n = context.zhL10n;
    final basic = _basicFields();
    if (basic['name']!.isEmpty) {
      _message(l10n.profileUsernameEmpty);
      return;
    }
    if (basic['name']!.runes.length > 16 ||
        basic['headline']!.runes.length > 100 ||
        basic['description']!.runes.length > 500) {
      _message(l10n.profileFieldTooLong);
      return;
    }
    final changedBasic = <String, String>{};
    for (final entry in basic.entries) {
      if (_originalBasic[entry.key] != entry.value) {
        changedBasic[entry.key] = entry.value;
      }
    }
    final advanced = _advancedFields();
    final advancedChanged = jsonEncode(advanced) != _originalAdvanced;
    if (changedBasic.isEmpty && !advancedChanged) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() => _saving = true);
    try {
      if (changedBasic.isNotEmpty) {
        final response = await widget.api.updateAccountProfile(changedBasic);
        _requireSuccess(response);
      }
      if (advancedChanged) {
        final response = await widget.api.updateAccountProfileV2(
          educations: _educations,
          employments: _employments,
          locations: (advanced['locations']! as List)
              .cast<Map<String, Object?>>(),
        );
        _requireSuccess(response);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) _message(ApiFailure.from(error).detail);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _requireSuccess(ApiResponse response) {
    if (!response.isSuccess) throw response;
  }

  Future<void> _pickAndUpload({required bool cover}) async {
    if (_saving || _uploadingImage != null) return;
    final l10n = context.zhL10n;
    try {
      final picked = await NativeImagePicker.pickSingleImage();
      if (!mounted || picked == null) return;
      setState(() => _uploadingImage = cover ? 'cover' : 'avatar');
      final uploaded = await widget.api.uploadProfileImage(
        bytes: picked.bytes,
        fileName: picked.fileName,
        mimeType: picked.mimeType,
      );
      _requireSuccess(uploaded);
      final image = _findUploadedImage(uploaded.json);
      final url = _firstText(image, const ['url', 'src', 'original_src']);
      if (url.isEmpty) {
        throw ApiTransportException(l10n.profileImageUploadNoUrl);
      }
      if (cover) {
        final hash = _firstText(image, const ['hash', 'image_hash']);
        if (hash.isEmpty) {
          throw ApiTransportException(l10n.profileCoverUploadNoHash);
        }
        final response = await widget.api.updateAccountCover(hash);
        _requireSuccess(response);
        widget.profile['cover_url'] = url;
      } else {
        final response = await widget.api.updateAccountAvatar(url);
        _requireSuccess(response);
        widget.profile['avatar_url'] = url;
        widget.profile['avatar_url_template'] = url;
      }
      if (mounted) {
        setState(() => _uploadingImage = null);
        _message(cover ? l10n.profileCoverUpdated : l10n.profileAvatarUpdated);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _uploadingImage = null);
        _message(ApiFailure.from(error).detail);
      }
    }
  }

  Map<String, dynamic> _findUploadedImage(Object? value) {
    if (value is Map) {
      final map = <String, dynamic>{
        for (final entry in value.entries)
          if (entry.key is String) entry.key as String: entry.value,
      };
      if (const [
        'url',
        'src',
        'original_src',
        'hash',
        'image_hash',
      ].any(map.containsKey)) {
        return map;
      }
      for (final child in map.values) {
        final result = _findUploadedImageOrNull(child);
        if (result != null) return result;
      }
    } else if (value is List) {
      for (final child in value) {
        final result = _findUploadedImageOrNull(child);
        if (result != null) return result;
      }
    }
    return const <String, dynamic>{};
  }

  Map<String, dynamic>? _findUploadedImageOrNull(Object? value) {
    if (value is Map || value is List) {
      final result = _findUploadedImage(value);
      return result.isEmpty ? null : result;
    }
    return null;
  }

  String _firstText(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = plainText(map[key]).trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _editText({
    required String title,
    required String value,
    required int maxLength,
    required ValueChanged<String> apply,
    int maxLines = 1,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _ProfileTextEditorSheet(
        title: title,
        value: value,
        maxLength: maxLength,
        maxLines: maxLines,
      ),
    );
    if (!mounted || result == null) return;
    setState(() => apply(result));
  }

  Future<void> _selectGender() async {
    final l10n = context.zhL10n;
    final values = [
      ('female', l10n.profileGenderFemale),
      ('male', l10n.profileGenderMale),
      ('', l10n.profileGenderUnspecified),
    ];
    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.profileGender,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              for (final (value, label) in values)
                ListTile(
                  title: Text(label),
                  trailing: value == _gender
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.of(context).pop(value),
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _gender = result);
  }

  Future<void> _selectBirthday() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: _profileBirthday({'birthday': _birthday}) ?? DateTime(2000),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _birthday =
          '${selected.year}-${selected.month.toString().padLeft(2, '0')}-'
          '${selected.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _addEmployment() async {
    final l10n = context.zhL10n;
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _ProfilePairEditorSheet(
        title: l10n.profileAddEmployment,
        firstLabel: l10n.profileCompanyOrOrganization,
        secondLabel: l10n.profileJob,
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _employments.add({'company': result[0], 'job': result[1]}));
  }

  Future<void> _addEducation() async {
    final l10n = context.zhL10n;
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _ProfilePairEditorSheet(
        title: l10n.profileAddEducation,
        firstLabel: l10n.profileSchool,
        secondLabel: l10n.profileMajor,
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _educations.add({
        'school': result[0],
        'major': result[1],
        'entrance_year': '',
        'graduation_year': '',
        'diploma': '',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.zhL10n;
    final avatar = plainText(
      widget.profile['avatar_url'] ?? widget.profile['avatar_url_template'],
    );
    final cover = plainText(widget.profile['cover_url']);
    return Scaffold(
      appBar: ZhTopBar(
        leading: ZhLiquidGlassIconButton(
          size: 46,
          iconSize: 24,
          semanticLabel: l10n.commonClose,
          onPressed: _saving || _uploadingImage != null
              ? null
              : () => Navigator.of(context).pop(false),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(l10n.profileEditTitle),
        actions: [
          ZhLiquidGlassLabelButton(
            onPressed: _saving || _uploadingImage != null ? null : _save,
            label: _saving ? l10n.profileSaving : l10n.commonSave,
            prominent: true,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 44),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            color: ZhPalette.canvas,
            child: Text(
              l10n.profileInfoNotice,
              style: TextStyle(color: ZhPalette.subtleInk),
            ),
          ),
          _ProfileImageEditRow(
            label: l10n.profileAvatar,
            uploading: _uploadingImage == 'avatar',
            onTap: _saving || _uploadingImage != null
                ? null
                : () => _pickAndUpload(cover: false),
            preview: CircleAvatar(
              radius: 30,
              backgroundColor: ZhPalette.canvas,
              backgroundImage: Uri.tryParse(avatar)?.scheme == 'https'
                  ? ZhihuCachedNetworkImageProvider(
                      avatar,
                      headers: zhihuImageRequestHeaders,
                    )
                  : null,
              child: Uri.tryParse(avatar)?.scheme == 'https'
                  ? null
                  : const Icon(Icons.person_outline_rounded, size: 28),
            ),
          ),
          _ProfileImageEditRow(
            label: l10n.profileCover,
            uploading: _uploadingImage == 'cover',
            onTap: _saving || _uploadingImage != null
                ? null
                : () => _pickAndUpload(cover: true),
            preview: _ProfileImagePreview(imageUrl: cover),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.profileBasicInfo,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _ProfileEditRow(
            label: l10n.profileUsername,
            value: _name,
            onTap: () => _editText(
              title: l10n.profileUsername,
              value: _name,
              maxLength: 16,
              apply: (value) => _name = value,
            ),
          ),
          _ProfileEditRow(
            label: l10n.profileHeadline,
            value: _headline,
            placeholder: l10n.profileHeadlinePlaceholder,
            onTap: () => _editText(
              title: l10n.profileHeadline,
              value: _headline,
              maxLength: 100,
              maxLines: 5,
              apply: (value) => _headline = value,
            ),
          ),
          _ProfileEditRow(
            label: l10n.profileGender,
            value: profileGenderLabel(_gender, l10n),
            onTap: _selectGender,
          ),
          _ProfileEditRow(
            label: l10n.profileBirthday,
            value: _birthday,
            placeholder: l10n.profileBirthdayPlaceholder,
            onTap: _selectBirthday,
          ),
          _ProfileEditRow(
            label: l10n.profileLocation,
            value: _location,
            placeholder: l10n.profileLocationPlaceholder,
            onTap: () => _editText(
              title: l10n.profileLocation,
              value: _location,
              maxLength: 40,
              apply: (value) => _location = value,
            ),
          ),
          _ProfileEditRow(
            label: l10n.profileIndustry,
            value: _business,
            placeholder: l10n.profileIndustryPlaceholder,
            onTap: () => _editText(
              title: l10n.profileIndustry,
              value: _business,
              maxLength: 40,
              apply: (value) => _business = value,
            ),
          ),
          _ProfileListEditor(
            title: l10n.profileEmployment,
            actionLabel: l10n.profileAddEmployment,
            rows: [
              for (final item in _employments)
                '${plainText(item['company'])} · ${plainText(item['job'])}',
            ],
            onAdd: _addEmployment,
            onRemove: (index) => setState(() => _employments.removeAt(index)),
          ),
          _ProfileListEditor(
            title: l10n.profileEducation,
            actionLabel: l10n.profileAddEducation,
            rows: [
              for (final item in _educations)
                '${plainText(item['school'])} · ${plainText(item['major'])}',
            ],
            onAdd: _addEducation,
            onRemove: (index) => setState(() => _educations.removeAt(index)),
          ),
          _ProfileListEditor(
            title: l10n.profilePersonalVerification,
            actionLabel: l10n.profileAddVerification,
            rows: [],
          ),
          const SizedBox(height: 28),
          Text(l10n.profileBio, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _editText(
              title: l10n.profileBio,
              value: _description,
              maxLength: 500,
              maxLines: 10,
              apply: (value) => _description = value,
            ),
            child: Container(
              constraints: const BoxConstraints(minHeight: 86),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: ZhPalette.border)),
              ),
              child: Text(
                _description.isEmpty
                    ? l10n.profileBioPlaceholder
                    : _description,
                style: TextStyle(
                  color: _description.isEmpty
                      ? ZhPalette.subtleInk
                      : ZhPalette.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
