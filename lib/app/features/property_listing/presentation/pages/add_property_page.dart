import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'services/property_service.dart';
import 'models/property_model.dart';

class AddPropertyPage extends StatefulWidget {
  final void Function(Property property)? onSubmit;
  final String userId; // Required for API calls

  const AddPropertyPage({
    super.key,
    required this.userId,
    this.onSubmit,
  });

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  int _currentStep = 0;
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());
  bool _isSubmitting = false;

  // Image picker
  final ImagePicker _picker = ImagePicker();
  final PropertyService _propertyService;

  // Controllers remain the same...
  // ... (keep all your controllers and state variables as they are)

  _AddPropertyPageState() : _propertyService = PropertyService(userId: '');

  @override
  void initState() {
    super.initState();
    // Initialize service with user ID
    _propertyService = PropertyService(userId: widget.userId);
  }

  // ... (keep all your existing methods: dispose, _nextStep, _backStep, etc.)

  // Update _buildPayload to return Property object
  Property _buildProperty() {
    return Property(
      userId: widget.userId,
      title: _titleController.text.trim(),
      category: _category,
      type: _propertyType,
      rent: int.tryParse(_rentController.text.trim()) ?? 0,
      isNegotiable: _isNegotiable,
      minBidAmount: int.tryParse(_minBidController.text.trim()),
      bedrooms: _bedrooms,
      bathrooms: _bathrooms,
      floor: int.tryParse(_floorController.text.trim()),
      size: int.tryParse(_sizeController.text.trim()),
      furnished: _furnished,
      availableFrom: _availableFrom,
      amenities: _selectedAmenities.toList(),
      images: _images,
      featureImage: _featureImage,
      address: Address(
        area: _areaController.text.trim(),
        road: _roadController.text.trim(),
        houseNo: _houseController.text.trim(),
        fullAddress: _addressController.text.trim(),
        latitude: double.tryParse(_latController.text.trim()),
        longitude: double.tryParse(_lngController.text.trim()),
      ),
      owner: Owner(
        name: _ownerNameController.text.trim(),
        phone: _ownerPhoneController.text.trim(),
        altPhone: _ownerAltPhoneController.text.trim(),
        email: _ownerEmailController.text.trim(),
        allowCall: _allowCall,
        messageOnly: _messageOnly,
      ),
    );
  }

  // Update _submit method to use API
  Future<void> _submit() async {
    // Validate final step forms
    for (var i = 0; i < _formKeys.length; i++) {
      final form = _formKeys[i];
      if (form.currentState != null && !form.currentState!.validate()) {
        setState(() => _currentStep = i);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill required fields')),
        );
        return;
      }
    }

    if (_images.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 4 images')),
      );
      setState(() => _currentStep = 2);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final property = _buildProperty();

      // Call API
      final response = await _propertyService.createProperty(property);

      if (response.success && response.data != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );

        // Invoke callback
        widget.onSubmit?.call(response.data!);

        // Optionally navigate back or reset form
        if (mounted) {
          Navigator.pop(context, response.data);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // Update _showPreviewAndSubmit to use Property object
  void _showPreviewAndSubmit() {
    final property = _buildProperty();
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
                  const Text(
                    'Preview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (property.featureImage != null)
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Builder(builder: (ctx) {
                              final img = property.featureImage!;
                              if (img.startsWith('http')) {
                                return Image.network(
                                  img,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) =>
                                  const Icon(Icons.broken_image),
                                );
                              }
                              if (kIsWeb) {
                                return const Icon(Icons.image);
                              }
                              return Image.file(
                                File(img),
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) =>
                                const Icon(Icons.broken_image),
                              );
                            }),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        property.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text('${property.category} • ${property.type}'),
                      const SizedBox(height: 8),
                      Text('Rent: ${property.rent} BDT'),
                      const SizedBox(height: 8),
                      Text('Amenities: ${property.amenities.join(', ')}'),
                      const SizedBox(height: 8),
                      const Text(
                        'Address',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(property.address?.fullAddress ?? ''),
                      const SizedBox(height: 8),
                      Text(
                        'Latitude: ${property.address?.latitude}, Longitude: ${property.address?.longitude}',
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Owner',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(property.owner?.name ?? ''),
                      Text(property.owner?.phone ?? ''),
                      const SizedBox(height: 12),
                      const Text(
                        'Images',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: property.images.map((u) {
                          return Image.network(
                            u,
                            width: 100,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 100,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                      Navigator.pop(ctx);
                      _submit();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(ctx).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                        : const Text('Submit Property'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(ctx).primaryColor,
                      side: BorderSide(
                        color: Theme.of(ctx).primaryColor,
                        width: 1.2,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

// ... (keep the rest of your build method the same)
}