import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPropertyPage extends StatefulWidget {
  final void Function(Map<String, dynamic> payload)? onSubmit;

  const AddPropertyPage({super.key, this.onSubmit});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  int _currentStep = 0;
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // STEP 1 - Basic Details
  final TextEditingController _titleController = TextEditingController();
  String _category = 'Family';
  String _propertyType = 'Full Apartment';
  final TextEditingController _rentController = TextEditingController();
  bool _isNegotiable = false;
  final TextEditingController _minBidController = TextEditingController();

  // STEP 2 - Property Info
  int _bedrooms = 1;
  int _bathrooms = 1;
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  bool _furnished = false;
  DateTime? _availableFrom;
  final List<String> _amenities = ['Wifi', 'Parking', 'Lift', 'Generator', 'CCTV', 'Gas', 'Electricity', 'Market'];
  final Set<String> _selectedAmenities = {};

  // STEP 3 - Media
  final List<String> _images = []; // store image URLs
  String? _featureImage;

  // STEP 4 - Location & Owner
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _roadController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerPhoneController = TextEditingController();
  final TextEditingController _ownerAltPhoneController = TextEditingController();
  final TextEditingController _ownerEmailController = TextEditingController();
  bool _allowCall = true;
  bool _messageOnly = false;

  @override
  void dispose() {
    _titleController.dispose();
    _rentController.dispose();
    _minBidController.dispose();
    _floorController.dispose();
    _sizeController.dispose();
    _areaController.dispose();
    _roadController.dispose();
    _houseController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _ownerAltPhoneController.dispose();
    _ownerEmailController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final currentForm = _formKeys[_currentStep];
    if (currentForm.currentState != null) {
      if (!currentForm.currentState!.validate()) return;
      currentForm.currentState!.save();
    }

    if (_currentStep < 4 - 1) {
      setState(() => _currentStep += 1);
    }
  }

  void _backStep() {
    if (_currentStep > 0) setState(() => _currentStep -= 1);
  }

  // Add image via URL dialog
  Future<void> _addImageUrl() async {
    final urlController = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Image URL'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(hintText: 'https://example.com/image.jpg'),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, urlController.text.trim()), child: const Text('Add')),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      if (_images.length >= 10) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 10 images allowed')));
        return;
      }
      setState(() {
        _images.add(result);
        _featureImage ??= result;
      });
    }
  }

  // Pick images from gallery / file picker
  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile>? picked = await _picker.pickMultiImage();
      if (picked == null || picked.isEmpty) return;

      final toAdd = picked.map((x) => x.path).toList();
      if (_images.length + toAdd.length > 10) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 10 images allowed')));
        return;
      }
      setState(() {
        _images.addAll(toAdd);
        _featureImage ??= _images.isNotEmpty ? _images.first : null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick images: $e')));
    }
  }

  // Remove image
  void _removeImage(int index) {
    setState(() {
      if (_featureImage == _images[index]) _featureImage = null;
      _images.removeAt(index);
    });
  }

  // Date picker for availableFrom
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _availableFrom ?? now,
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _availableFrom = picked);
  }

  // Map hint - since GoogleMap can crash without API, explain and allow manual entry
  Future<void> _showMapDisabledDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Map unavailable'),
        content: const Text(
            'Google Maps integration is disabled in this build to avoid runtime crashes when no API key is configured.\n\nYou can enter latitude and longitude manually, or enable Maps by adding an API key to AndroidManifest.xml and iOS config.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  // Assemble payload
  Map<String, dynamic> _buildPayload() {
    return {
      'title': _titleController.text.trim(),
      'category': _category,
      'type': _propertyType,
      'rent': int.tryParse(_rentController.text.trim()) ?? 0,
      'isNegotiable': _isNegotiable,
      'minBidAmount': int.tryParse(_minBidController.text.trim()) ?? null,
      'bedrooms': _bedrooms,
      'bathrooms': _bathrooms,
      'floor': int.tryParse(_floorController.text.trim()) ?? null,
      'size': int.tryParse(_sizeController.text.trim()) ?? null,
      'furnished': _furnished,
      'availableFrom': _availableFrom?.toIso8601String(),
      'amenities': _selectedAmenities.toList(),
      'images': _images,
      'featureImage': _featureImage,
      'address': {
        'area': _areaController.text.trim(),
        'road': _roadController.text.trim(),
        'houseNo': _houseController.text.trim(),
        'fullAddress': _addressController.text.trim(),
        'latitude': double.tryParse(_latController.text.trim()) ?? null,
        'longitude': double.tryParse(_lngController.text.trim()) ?? null,
      },
      'owner': {
        'name': _ownerNameController.text.trim(),
        'phone': _ownerPhoneController.text.trim(),
        'altPhone': _ownerAltPhoneController.text.trim(),
        'email': _ownerEmailController.text.trim(),
        'allowCall': _allowCall,
        'messageOnly': _messageOnly,
      }
    };
  }

  // Submit - currently just prints JSON and shows snackbar
  void _submit() {
    // Validate final step forms
    for (var i = 0; i < _formKeys.length; i++) {
      final form = _formKeys[i];
      if (form.currentState != null && !form.currentState!.validate()) {
        setState(() => _currentStep = i);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill required fields')));
        return;
      }
    }

    if (_images.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least 4 images')));
      setState(() => _currentStep = 2);
      return;
    }

    final payload = _buildPayload();
    // For now we just print the JSON. Replace this with API call to backend.
    debugPrint(const JsonEncoder.withIndent('  ').convert(payload));

    // Invoke optional callback so parent can update UI (e.g. show the new property on Home)
    try {
      widget.onSubmit?.call(payload);
    } catch (_) {}

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property submitted (see console)')));

    // Optionally reset the form or navigate away
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Property')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 3) {
            // Last step -> show preview (we treat step 3 as location/owner, step 4 preview handled by Submit button)
            _nextStep();
            return;
          }
          _nextStep();
        },
        onStepCancel: _backStep,
        controlsBuilder: (context, details) {
          final isLast = _currentStep == 3;
          return Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(isLast ? 'Preview' : 'Next'),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  OutlinedButton(onPressed: details.onStepCancel, child: const Text('Back')),
                const Spacer(),
                TextButton(onPressed: () {
                  // Save Draft stub
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved (not really)')));
                }, child: const Text('Save Draft')),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Basic Details'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Form(
              key: _formKeys[0],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Property Title'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _category,
                    items: ['Family', 'Bachelor', 'Student', 'Sublet', 'Shared Room', 'Mess/Hostel']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _category = v ?? _category),
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _propertyType,
                    items: ['Full Apartment', 'Single Room', 'Studio Room', 'Seat (Mess)']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _propertyType = v ?? _propertyType),
                    decoration: const InputDecoration(labelText: 'Property Type'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _rentController,
                    decoration: const InputDecoration(labelText: 'Monthly Rent (BDT)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Rent is required' : null,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Negotiable'),
                      const SizedBox(width: 8),
                      Switch(value: _isNegotiable, onChanged: (v) => setState(() => _isNegotiable = v)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _minBidController,
                          decoration: const InputDecoration(labelText: 'Min Bid Amount (optional)'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Property Information'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Form(
              key: _formKeys[1],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Bedrooms'),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                IconButton(onPressed: () => setState(() => _bedrooms = (_bedrooms - 1).clamp(0, 100)), icon: const Icon(Icons.remove)),
                                Text('$_bedrooms'),
                                IconButton(onPressed: () => setState(() => _bedrooms = (_bedrooms + 1).clamp(0, 100)), icon: const Icon(Icons.add)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Bathrooms'),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                IconButton(onPressed: () => setState(() => _bathrooms = (_bathrooms - 1).clamp(0, 100)), icon: const Icon(Icons.remove)),
                                Text('$_bathrooms'),
                                IconButton(onPressed: () => setState(() => _bathrooms = (_bathrooms + 1).clamp(0, 100)), icon: const Icon(Icons.add)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _floorController,
                    decoration: const InputDecoration(labelText: 'Floor Number'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _sizeController,
                    decoration: const InputDecoration(labelText: 'Total Size (sq ft)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Furnished'),
                      const SizedBox(width: 8),
                      Switch(value: _furnished,inactiveTrackColor:Colors.grey, onChanged: (v) => setState(() => _furnished = v)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _pickDate, child: const Text('Available From')),
                  const SizedBox(height: 8),
                  if (_availableFrom != null)
                    Text('Available from: ${_availableFrom!.toLocal().toString().split(' ')[0]}', style: TextStyle(color: Colors.orange[700])),
                  const SizedBox(height: 12),
                  const Text('Amenities:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _amenities.map((a) {
                      final selected = _selectedAmenities.contains(a);
                      return FilterChip(
                        label: Text(a),
                        selected: selected,
                        onSelected: (v) => setState(() => v ? _selectedAmenities.add(a) : _selectedAmenities.remove(a)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Media (Photos / Video)'),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            content: Form(
              key: _formKeys[2],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Images (enter image URLs or pick from gallery)'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickImagesFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Pick from Gallery'),
                      ),
                      // const SizedBox(width: 12),
                      // ElevatedButton.icon(
                      //   onPressed: _addImageUrl,
                      //   icon: const Icon(Icons.link),
                      //   label: const Text('Add Image URL'),
                      //   style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._images.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final url = entry.value;
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              width: 100,
                              height: 80,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Builder(builder: (ctx) {
                                  // If the string looks like a network URL, use Image.network,
                                  // otherwise try Image.file for local paths.
                                  if (url.startsWith('http')) {
                                    return Image.network(url, fit: BoxFit.cover, errorBuilder: (ctx, e, st) => const Center(child: Icon(Icons.broken_image)));
                                  }
                                  if (kIsWeb) {
                                    // On web, file paths aren't available; show a placeholder.
                                    return const Center(child: Icon(Icons.image));
                                  }
                                  return Image.file(File(url), fit: BoxFit.cover, errorBuilder: (ctx, e, st) => const Center(child: Icon(Icons.broken_image)));
                                }),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _removeImage(idx),
                                child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                              ),
                            ),
                            if (_featureImage == url)
                              const Positioned(
                                left: 4,
                                bottom: 4,
                                child: Chip(label: Text('Feature', style: TextStyle(fontSize: 10)), backgroundColor: Colors.white70),
                              ),
                          ],
                        );
                      }),
                      if (_images.length < 10)
                        GestureDetector(
                          onTap: _addImageUrl,
                          child: Container(
                            width: 100,
                            height: 80,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[100], border: Border.all(color: Colors.grey[300]!)),
                            child: const Center(child: Icon(Icons.add_a_photo, color: Colors.black54)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_images.isNotEmpty)
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // Choose feature image
                            final choice = await showDialog<String?>(
                              context: context,
                              builder: (ctx) => SimpleDialog(
                                title: const Text('Choose Feature Image'),
                                children: _images
                                    .map((url) => SimpleDialogOption(
                                          child: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
                                          onPressed: () => Navigator.pop(ctx, url),
                                        ))
                                    .toList(),
                              ),
                            );
                            if (choice != null) setState(() => _featureImage = choice);
                          },
                          child: const Text('Set Feature Image'),
                        ),
                        const SizedBox(width: 12),
                        Text('${_images.length} images added'),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Step(
            title: const Text('Location & Owner'),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
            content: Form(
              key: _formKeys[3],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: _areaController, decoration: const InputDecoration(labelText: 'Area (e.g. Mirpur)'))),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: _showMapDisabledDialog, child: const Text('Pick on Map')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(controller: _roadController, decoration: const InputDecoration(labelText: 'Road / Block')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _houseController, decoration: const InputDecoration(labelText: 'House No')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Full Address')),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextFormField(controller: _latController, decoration: const InputDecoration(labelText: 'Latitude'))),
                      const SizedBox(width: 8),
                      Expanded(child: TextFormField(controller: _lngController, decoration: const InputDecoration(labelText: 'Longitude'))),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text('Owner Contact', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(controller: _ownerNameController, decoration: const InputDecoration(labelText: 'Owner Name')),
                  const SizedBox(height: 8),
                  TextFormField(controller: _ownerPhoneController, decoration: const InputDecoration(labelText: 'Phone (BD)'), keyboardType: TextInputType.phone),
                  const SizedBox(height: 8),
                  TextFormField(controller: _ownerAltPhoneController, decoration: const InputDecoration(labelText: 'Alternative Phone (optional)'), keyboardType: TextInputType.phone),
                  const SizedBox(height: 8),
                  TextFormField(controller: _ownerEmailController, decoration: const InputDecoration(labelText: 'Email (optional)'), keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Allow Call'),
                      const SizedBox(width: 8),
                      Switch(value: _allowCall,inactiveTrackColor:Colors.grey, onChanged: (v) => setState(() => _allowCall = v)),
                      const SizedBox(width: 16),
                      const Text('Message Only'),
                      const SizedBox(width: 8),
                      Switch(value: _messageOnly,inactiveTrackColor:Colors.grey, onChanged: (v) => setState(() => _messageOnly = v)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _currentStep == 3
          ? FloatingActionButton.extended(
              onPressed: () => _showPreviewAndSubmit(),
              label: const Text('Preview & Submit'),
              icon: const Icon(Icons.preview),
            )
          : null,
    );
  }

  void _showPreviewAndSubmit() {
    final payload = _buildPayload();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.9,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_featureImage != null)
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Builder(builder: (ctx) {
                              final img = _featureImage!;
                              if (img.startsWith('http')) {
                                return Image.network(img, height: 180, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image));
                              }
                              if (kIsWeb) {
                                return const Icon(Icons.image);
                              }
                              return Image.file(File(img), height: 180, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image));
                            }),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(payload['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('${payload['category']} • ${payload['type']}'),
                      const SizedBox(height: 8),
                      Text('Rent: ${payload['rent']} BDT'),
                      const SizedBox(height: 8),
                      Text('Amenities: ${(payload['amenities'] as List).join(', ')}'),
                      const SizedBox(height: 8),
                      const Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(payload['address']['fullAddress'] ?? ''),
                      const SizedBox(height: 8),
                      Text('Latitude: ${payload['address']['latitude']}, Longitude: ${payload['address']['longitude']}'),
                      const SizedBox(height: 12),
                      const Text('Owner', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(payload['owner']['name'] ?? ''),
                      Text(payload['owner']['phone'] ?? ''),
                      const SizedBox(height: 12),
                      const Text('Images', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(spacing: 8, runSpacing: 8, children: _images.map((u) => Image.network(u, width: 100, height: 80, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 100, height: 80, color: Colors.grey[200], child: const Icon(Icons.broken_image)))).toList()),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _submit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(ctx).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 4,
                    ),
                    child: const Text('Submit Property'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(ctx).primaryColor,
                      side: BorderSide(color: Theme.of(ctx).primaryColor, width: 1.2),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
