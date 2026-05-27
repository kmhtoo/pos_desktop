import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/pos_provider.dart';
import 'pos_screen.dart';

const _validCredentials = {
  '1001': '1234',
  '1002': '5678',
  '9999': '0000',
};

const _userInfo = {
  '1001': ('Alex Chen', 'Cashier'),
  '1002': ('Morgan Lee', 'Manager'),
  '9999': ('System Admin', 'Administrator'),
};

enum _Field { userId, code }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _userIdInput = '';
  String _codeInput = '';
  _Field _activeField = _Field.userId;
  String? _errorMessage;
  bool _isLoading = false;

  void _onKey(String key) {
    if (_isLoading) return;
    setState(() {
      _errorMessage = null;
      if (key == '⌫') {
        if (_activeField == _Field.userId) {
          if (_userIdInput.isNotEmpty) {
            _userIdInput = _userIdInput.substring(0, _userIdInput.length - 1);
          }
        } else {
          if (_codeInput.isNotEmpty) {
            _codeInput = _codeInput.substring(0, _codeInput.length - 1);
          }
        }
      } else if (key == '↵') {
        if (_activeField == _Field.userId) {
          if (_userIdInput.isNotEmpty) {
            _activeField = _Field.code;
          } else {
            _errorMessage = 'Enter your User ID first';
          }
        } else {
          _triggerLogin();
        }
      } else {
        if (_activeField == _Field.userId) {
          if (_userIdInput.length < 10) _userIdInput += key;
        } else {
          if (_codeInput.length < 10) _codeInput += key;
        }
      }
    });
  }

  void _triggerLogin() {
    if (_userIdInput.isEmpty) {
      setState(() {
        _activeField = _Field.userId;
        _errorMessage = 'Enter your User ID';
      });
      return;
    }
    if (_codeInput.isEmpty) {
      setState(() => _errorMessage = 'Enter your Access Code');
      return;
    }
    _login();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (_validCredentials[_userIdInput] == _codeInput) {
      if (mounted) {
        final info = _userInfo[_userIdInput];
        final user = AppUser(
          id: _userIdInput,
          name: info?.$1 ?? 'User $_userIdInput',
          role: info?.$2 ?? 'Staff',
          loginTime: DateTime.now(),
        );
        context.read<PosProvider>().setUser(user);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const POSScreen()),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
        _codeInput = '';
        _activeField = _Field.code;
        _errorMessage = 'Invalid user ID or access code';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(height: 36),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: _buildCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: const Color(0xFF14B8A6).withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.point_of_sale,
            color: Color(0xFF14B8A6),
            size: 42,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'FlutterPOS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Point of Sale System',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cashier Sign In',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Tap a field, then use the keypad',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(height: 20),
          _buildDisplayField(
            label: 'User ID',
            value: _userIdInput,
            obscure: false,
            isActive: _activeField == _Field.userId,
            onTap: () => setState(() {
              _activeField = _Field.userId;
              _errorMessage = null;
            }),
          ),
          const SizedBox(height: 10),
          _buildDisplayField(
            label: 'Access Code',
            value: _codeInput,
            obscure: true,
            isActive: _activeField == _Field.code,
            onTap: () => setState(() {
              _activeField = _Field.code;
              _errorMessage = null;
            }),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            _buildErrorBanner(),
          ],
          const SizedBox(height: 16),
          _buildNumpad(),
          const SizedBox(height: 14),
          _buildSignInButton(),
          const SizedBox(height: 16),
          _buildDemoCredentials(),
        ],
      ),
    );
  }

  Widget _buildDisplayField({
    required String label,
    required String value,
    required bool obscure,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final display = obscure ? '●' * value.length : value;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? const Color(0xFF14B8A6)
                  : const Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 5),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF14B8A6)
                    : const Color(0xFF334155),
                width: isActive ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  obscure ? Icons.lock_outline : Icons.badge_outlined,
                  color: isActive
                      ? const Color(0xFF14B8A6)
                      : const Color(0xFF475569),
                  size: 17,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    display.isEmpty
                        ? (obscure ? 'Enter code' : 'Enter user ID')
                        : display,
                    style: TextStyle(
                      color: display.isEmpty
                          ? const Color(0xFF475569)
                          : Colors.white,
                      fontSize: obscure ? 22 : 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: obscure ? 6 : 0,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 2,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    const rows = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['⌫', '0', '↵'],
    ];
    final isConfirmOnCode = _activeField == _Field.code;

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: row.map((label) {
              final isBackspace = label == '⌫';
              final isConfirm = label == '↵';
              Color bgColor;
              Widget child;

              if (isConfirm) {
                bgColor = isConfirmOnCode
                    ? const Color(0xFF14B8A6)
                    : const Color(0xFF334155);
                child = Icon(
                  isConfirmOnCode ? Icons.check_rounded : Icons.arrow_forward,
                  color: Colors.white,
                  size: 22,
                );
              } else if (isBackspace) {
                bgColor = const Color(0xFF334155);
                child = const Icon(
                  Icons.backspace_outlined,
                  color: Color(0xFF94A3B8),
                  size: 20,
                );
              } else {
                bgColor = const Color(0xFF0F172A);
                child = Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => _onKey(label),
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: 58,
                        child: Center(child: child),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSignInButton() {
    final canSignIn = _userIdInput.isNotEmpty && _codeInput.isNotEmpty;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (_isLoading || !canSignIn) ? null : _triggerLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF14B8A6),
          disabledBackgroundColor: const Color(0xFF1E3A2F).withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          disabledForegroundColor: const Color(0xFF475569),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: 18),
                  SizedBox(width: 8),
                  Text('Sign In'),
                ],
              ),
      ),
    );
  }

  Widget _buildDemoCredentials() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF334155).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: const Color(0xFF475569).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF64748B), size: 13),
              SizedBox(width: 6),
              Text(
                'Demo Credentials',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          _buildCredRow('Cashier', '1001', '1234'),
          const SizedBox(height: 3),
          _buildCredRow('Manager', '1002', '5678'),
        ],
      ),
    );
  }

  Widget _buildCredRow(String role, String id, String code) {
    return Row(
      children: [
        SizedBox(
          width: 58,
          child: Text(role,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
        ),
        const Text('ID ',
            style: TextStyle(color: Color(0xFF475569), fontSize: 11)),
        Text(id,
            style: const TextStyle(
                color: Color(0xFF14B8A6),
                fontSize: 11,
                fontWeight: FontWeight.w700)),
        const SizedBox(width: 10),
        const Text('Code ',
            style: TextStyle(color: Color(0xFF475569), fontSize: 11)),
        Text(code,
            style: const TextStyle(
                color: Color(0xFF14B8A6),
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}
