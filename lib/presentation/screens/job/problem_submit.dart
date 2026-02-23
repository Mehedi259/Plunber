import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProblemSubmitScreen extends StatefulWidget {
  final String jobId;

  const ProblemSubmitScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<ProblemSubmitScreen> createState() => _ProblemSubmitScreenState();
}

class _ProblemSubmitScreenState extends State<ProblemSubmitScreen> {
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _selectedImages = [];

  @override
  void dispose() {
    _problemController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addPhoto() {
    // Implement image picker functionality
    setState(() {
      _selectedImages.add('photo_${_selectedImages.length + 1}');
    });
  }

  void _saveReport() {
    if (_problemController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save the problem report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Problem report saved successfully'),
        backgroundColor: Colors.green,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Problem',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF323232),
                ),
              ),
              const SizedBox(height: 32),

              // What Happened Field
              const Text(
                'What Happen?',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF323232),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _problemController,
                decoration: InputDecoration(
                  hintText: 'what is the problem',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[400],
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2563EB)),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Give Description Field
              const Text(
                'Give Description',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF323232),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'write description',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[400],
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2563EB)),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Add Photo Section
              const Text(
                'Add picture for more clarification',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF323232),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _addPhoto,
                icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
                label: const Text(
                  'Add Photo',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2563EB),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Display selected images
              if (_selectedImages.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedImages.map((image) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.remove(image);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 200),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
