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
    'gender': _gender == '女'
        ? '0'
        : _gender == '男'
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
    final basic = _basicFields();
    if (basic['name']!.isEmpty) {
      _message('用户名不能为空');
      return;
    }
    if (basic['name']!.runes.length > 16 ||
        basic['headline']!.runes.length > 100 ||
        basic['description']!.runes.length > 500) {
      _message('用户名、介绍或个人简介超过长度限制');
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
      if (url.isEmpty) throw const ApiTransportException('图片上传未返回地址');
      if (cover) {
        final hash = _firstText(image, const ['hash', 'image_hash']);
        if (hash.isEmpty) {
          throw const ApiTransportException('主页背景上传未返回图片哈希');
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
        _message(cover ? '主页背景已更新' : '头像已更新');
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
              Text('性别', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              for (final value in const ['女', '男', '未填写'])
                ListTile(
                  title: Text(value),
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
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => const _ProfilePairEditorSheet(
        title: '添加职业经历',
        firstLabel: '公司或组织',
        secondLabel: '职位',
      ),
    );
    if (!mounted || result == null) return;
    setState(() => _employments.add({'company': result[0], 'job': result[1]}));
  }

  Future<void> _addEducation() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => const _ProfilePairEditorSheet(
        title: '添加教育经历',
        firstLabel: '学校',
        secondLabel: '专业',
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
    final avatar = plainText(
      widget.profile['avatar_url'] ?? widget.profile['avatar_url_template'],
    );
    final cover = plainText(widget.profile['cover_url']);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: '关闭',
          onPressed: _saving || _uploadingImage != null
              ? null
              : () => Navigator.of(context).pop(false),
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text('编辑个人资料'),
        actions: [
          TextButton(
            onPressed: _saving || _uploadingImage != null ? null : _save,
            child: Text(_saving ? '保存中' : '保存'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 44),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            color: ZhPalette.canvas,
            child: const Text(
              '您填写的内容将用于个人页展示及内容推荐',
              style: TextStyle(color: ZhPalette.subtleInk),
            ),
          ),
          _ProfileImageEditRow(
            label: '头像',
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
            label: '主页背景',
            uploading: _uploadingImage == 'cover',
            onTap: _saving || _uploadingImage != null
                ? null
                : () => _pickAndUpload(cover: true),
            preview: _ProfileImagePreview(imageUrl: cover),
          ),
          const SizedBox(height: 18),
          Text('基本资料', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _ProfileEditRow(
            label: '用户名',
            value: _name,
            onTap: () => _editText(
              title: '用户名',
              value: _name,
              maxLength: 16,
              apply: (value) => _name = value,
            ),
          ),
          _ProfileEditRow(
            label: '一句话介绍',
            value: _headline,
            placeholder: '介绍自己的职业或兴趣',
            onTap: () => _editText(
              title: '一句话介绍',
              value: _headline,
              maxLength: 100,
              maxLines: 5,
              apply: (value) => _headline = value,
            ),
          ),
          _ProfileEditRow(label: '性别', value: _gender, onTap: _selectGender),
          _ProfileEditRow(
            label: '生日',
            value: _birthday,
            placeholder: '请填写生日',
            onTap: _selectBirthday,
          ),
          _ProfileEditRow(
            label: '居住地',
            value: _location,
            placeholder: '请填写居住地',
            onTap: () => _editText(
              title: '居住地',
              value: _location,
              maxLength: 40,
              apply: (value) => _location = value,
            ),
          ),
          _ProfileEditRow(
            label: '所在行业',
            value: _business,
            placeholder: '请选择行业',
            onTap: () => _editText(
              title: '所在行业',
              value: _business,
              maxLength: 40,
              apply: (value) => _business = value,
            ),
          ),
          _ProfileListEditor(
            title: '职业经历',
            actionLabel: '添加职业经历',
            rows: [
              for (final item in _employments)
                '${plainText(item['company'])} · ${plainText(item['job'])}',
            ],
            onAdd: _addEmployment,
            onRemove: (index) => setState(() => _employments.removeAt(index)),
          ),
          _ProfileListEditor(
            title: '教育经历',
            actionLabel: '添加教育经历',
            rows: [
              for (final item in _educations)
                '${plainText(item['school'])} · ${plainText(item['major'])}',
            ],
            onAdd: _addEducation,
            onRemove: (index) => setState(() => _educations.removeAt(index)),
          ),
          const _ProfileListEditor(
            title: '个人认证',
            actionLabel: '添加个人认证',
            rows: [],
          ),
          const SizedBox(height: 28),
          Text('个人简介', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _editText(
              title: '个人简介',
              value: _description,
              maxLength: 500,
              maxLines: 10,
              apply: (value) => _description = value,
            ),
            child: Container(
              constraints: const BoxConstraints(minHeight: 86),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: ZhPalette.border)),
              ),
              child: Text(
                _description.isEmpty ? '用一段话介绍自己' : _description,
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
