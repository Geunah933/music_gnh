import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/local_music_provider.dart';

/// Screen for uploading a local MP3 with cover art and metadata.
class UploadMusicScreen extends StatefulWidget {
  const UploadMusicScreen({super.key});

  @override
  State<UploadMusicScreen> createState() => _UploadMusicScreenState();
}

class _UploadMusicScreenState extends State<UploadMusicScreen> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();
  String? _mp3Path;
  String? _mp3FileName;
  String? _coverPath;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  Future<void> _pickMp3() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'aac', 'm4a', 'wav', 'flac', 'ogg'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _mp3Path = result.files.single.path;
        _mp3FileName = result.files.single.name;
        // Auto-fill title from filename (without extension)
        if (_titleController.text.isEmpty) {
          _titleController.text = result.files.single.name
              .replaceAll(RegExp(r'\.\w+$'), '')
              .replaceAll('_', ' ')
              .replaceAll('-', ' ');
        }
      });
    }
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _coverPath = image.path);
    }
  }

  Future<void> _save() async {
    if (_mp3Path == null) {
      _showSnackBar('Pilih file MP3 terlebih dahulu', isError: true);
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Masukkan judul lagu', isError: true);
      return;
    }
    if (_artistController.text.trim().isEmpty) {
      _showSnackBar('Masukkan nama artis', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final provider = context.read<LocalMusicProvider>();
      await provider.addTrack(
        sourceFilePath: _mp3Path!,
        coverFilePath: _coverPath,
        title: _titleController.text.trim(),
        artistName: _artistController.text.trim(),
        albumName: _albumController.text.trim().isEmpty
            ? 'My Music'
            : _albumController.text.trim(),
      );

      if (mounted) {
        _showSnackBar('Lagu berhasil ditambahkan! ✓');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal menyimpan: $e', isError: true);
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Lagu',
          style: AppTextStyles.headlineMedium.copyWith(
            color: cs.onSurface,
          ),
        ),
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover Art ──
            Center(
              child: GestureDetector(
                onTap: _pickCover,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                    image: _coverPath != null
                        ? DecorationImage(
                            image: FileImage(File(_coverPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _coverPath == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_rounded,
                                size: 48, color: cs.primary),
                            const SizedBox(height: 8),
                            Text(
                              'Tambah Cover',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: cs.primary,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── MP3 Picker ──
            _buildSectionLabel('FILE MUSIK', cs),
            const SizedBox(height: 8),
            Material(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickMp3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _mp3Path != null
                          ? cs.primary.withValues(alpha: 0.5)
                          : cs.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _mp3Path != null
                            ? Icons.audio_file_rounded
                            : Icons.upload_file_rounded,
                        color: _mp3Path != null ? cs.primary : cs.onSurfaceVariant,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _mp3FileName ?? 'Pilih file MP3',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: _mp3Path != null
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_mp3Path == null)
                              Text(
                                'MP3, AAC, M4A, WAV, FLAC, OGG',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_mp3Path != null)
                        Icon(Icons.check_circle_rounded,
                            color: cs.primary, size: 22),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Metadata Fields ──
            _buildSectionLabel('INFORMASI LAGU', cs),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _titleController,
              label: 'Judul Lagu *',
              icon: Icons.music_note_rounded,
              cs: cs,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _artistController,
              label: 'Artis *',
              icon: Icons.person_rounded,
              cs: cs,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _albumController,
              label: 'Album (opsional)',
              icon: Icons.album_rounded,
              cs: cs,
            ),
            const SizedBox(height: 32),

            // ── Save Button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                icon: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onPrimary,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'SIMPAN LAGU',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, ColorScheme cs) {
    return Text(
      text,
      style: AppTextStyles.labelCaps.copyWith(
        color: cs.primary,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme cs,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        prefixIcon: Icon(icon, color: cs.primary),
        filled: true,
        fillColor: cs.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary),
        ),
      ),
    );
  }
}
