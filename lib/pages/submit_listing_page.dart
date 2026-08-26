import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/listings_provider.dart';
import '../theme/app_colors.dart';

class SubmitListingPage extends StatefulWidget {
  const SubmitListingPage({super.key});

  @override
  State<SubmitListingPage> createState() => _SubmitListingPageState();
}

class _SubmitListingPageState extends State<SubmitListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _address = TextEditingController();
  final _bedrooms = TextEditingController(text: '1');
  final _bathrooms = TextEditingController(text: '1');

  String _propertyType = 'house';
  String _listingType = 'rent';
  String? _locationId;
  final List<XFile> _photos = [];
  bool _busy = false;
  int _step = 0;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    _address.dispose();
    _bedrooms.dispose();
    _bathrooms.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;
    setState(() {
      _photos.addAll(files.take(8 - _photos.length));
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one photo')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<ListingsProvider>().createListing(
            title: _title.text.trim(),
            description: _description.text.trim(),
            propertyType: _propertyType,
            listingType: _listingType,
            price: num.parse(_price.text.trim()),
            bedrooms: int.tryParse(_bedrooms.text.trim()) ?? 0,
            bathrooms: int.tryParse(_bathrooms.text.trim()) ?? 0,
            address: _address.text.trim(),
            locationId: _locationId,
            photoPaths: _photos.map((e) => e.path).toList(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submitted for admin review'),
        ),
      );
      context.go('/my-listings');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locations = context.watch<ListingsProvider>().locations;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_step == 0 ? 'Property details' : 'Photos & submit'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            LinearProgressIndicator(
              value: (_step + 1) / 2,
              color: AppColors.brand500,
              backgroundColor: AppColors.brand50,
            ),
            const SizedBox(height: 20),
            if (_step == 0) ...[
              DropdownButtonFormField<String>(
                value: _propertyType,
                decoration: const InputDecoration(labelText: 'Property type'),
                items: const [
                  DropdownMenuItem(value: 'house', child: Text('House')),
                  DropdownMenuItem(
                      value: 'apartment', child: Text('Apartment')),
                  DropdownMenuItem(value: 'villa', child: Text('Villa')),
                ],
                onChanged: (v) => setState(() => _propertyType = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _listingType,
                decoration: const InputDecoration(labelText: 'Listing type'),
                items: const [
                  DropdownMenuItem(value: 'rent', child: Text('For rent')),
                  DropdownMenuItem(value: 'sale', child: Text('For sale')),
                ],
                onChanged: (v) => setState(() => _listingType = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _listingType == 'rent'
                      ? 'Price (RWF / month)'
                      : 'Price (RWF)',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (num.tryParse(v) == null) return 'Enter a number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bedrooms,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Bedrooms'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bathrooms,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Bathrooms'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                value: _locationId,
                decoration: const InputDecoration(labelText: 'Location'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Select area'),
                  ),
                  ...locations.map(
                    (l) => DropdownMenuItem(value: l.id, child: Text(l.name)),
                  ),
                ],
                onChanged: (v) => setState(() => _locationId = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(
                  labelText: 'Street address / landmark',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _step = 1);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brand500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Next: photos'),
              ),
            ] else ...[
              OutlinedButton.icon(
                onPressed: _photos.length >= 8 ? null : _pickPhotos,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text('Add photos (${_photos.length}/8)'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _photos.length; i++)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_photos[i].path),
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => setState(() => _photos.removeAt(i)),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : () => setState(() => _step = 0),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _busy ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brand500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Submit for review'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
