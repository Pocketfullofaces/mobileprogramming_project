import 'package:flutter/material.dart';

import '../main_screen.dart';
import '../services/social_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _email = TextEditingController();
  bool _register = false, _busy = false, _hide = true;
  String? _error;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_register) {
        await SocialService.instance.register(
          _username.text,
          _email.text,
          _password.text,
        );
        if (!mounted) return;
        setState(() {
          _register = false;
          _password.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Register berhasil. Silakan login dengan username dan password.',
            ),
          ),
        );
      } else {
        await SocialService.instance.login(_username.text, _password.text);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.directions_run,
                    size: 64,
                    color: Color(0xFFFC4C02),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _register ? 'Buat akun' : 'Selamat datang',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _register
                        ? 'Daftar dulu untuk berbagi aktivitas dengan teman.'
                        : 'Masuk dengan username dan password kamu.',
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _username,
                    enabled: !_busy,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      helperText:
                          '3–20 karakter: huruf, angka, titik, atau underscore',
                    ),
                    validator: (v) => validUsername(v ?? '')
                        ? null
                        : 'Username harus 3–20 karakter tanpa spasi.',
                  ),
                  if (_register) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      enabled: !_busy,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Gmail'),
                      validator: (v) =>
                          RegExp(r'^[^\s@]+@gmail\.com$')
                              .hasMatch((v ?? '').trim().toLowerCase())
                          ? null
                          : 'Masukkan alamat Gmail yang valid.',
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    enabled: !_busy,
                    obscureText: _hide,
                    onFieldSubmitted: (_) {
                      if (!_busy) _submit();
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        tooltip: _hide
                            ? 'Tampilkan password'
                            : 'Sembunyikan password',
                        onPressed: () => setState(() => _hide = !_hide),
                        icon: Icon(
                          _hide ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (v) => (v ?? '').length >= 6
                        ? null
                        : 'Password minimal 6 karakter.',
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_register ? 'Register' : 'Login'),
                  ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                            _register = !_register;
                            _error = null;
                            _password.clear();
                            _form.currentState?.reset();
                          }),
                    child: Text(
                      _register
                          ? 'Sudah punya akun? Login'
                          : 'Belum punya akun? Register',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
