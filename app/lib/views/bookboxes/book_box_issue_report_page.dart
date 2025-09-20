// app/lib/pages/bookbox/book_box_issue_report_page.dart
import 'package:Lino_app/vm/bookboxes/book_box_issue_report_view_model.dart';
import 'package:Lino_app/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/l10n/app_localizations.dart';

class BookBoxIssueReportPage extends StatefulWidget {
  final String bookboxId;

  const BookBoxIssueReportPage({super.key, required this.bookboxId});

  @override
  State<BookBoxIssueReportPage> createState() => _BookBoxIssueReportPageState();
}

class _BookBoxIssueReportPageState extends State<BookBoxIssueReportPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookBoxIssueReportViewModel>().checkUserStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookBoxIssueReportViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color.fromRGBO(245, 245, 235, 1),
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.reportIssue,
              style: TextStyle(
                fontFamily: 'Kanit',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: LinoColors.accent,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSubjectField(viewModel),
                  const SizedBox(height: 16),
                  _buildDescriptionField(viewModel),
                  const SizedBox(height: 16),
                  _buildEmailField(viewModel),
                  const SizedBox(height: 24),
                  _buildSubmitButton(viewModel),
                  const SizedBox(height: 16),
                  _buildInfoText(viewModel),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.report_problem, color: Colors.orange.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.reportProblemTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Kanit',
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.reportProblemDescription,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Kanit',
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectField(BookBoxIssueReportViewModel viewModel) {
    return TextFormField(
      controller: viewModel.subjectController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.subject,
        hintText: AppLocalizations.of(context)!.briefDescriptionOfIssue,
        prefixIcon: const Icon(Icons.title),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppLocalizations.of(context)!.subjectRequired;
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField(BookBoxIssueReportViewModel viewModel) {
    return TextFormField(
      controller: viewModel.descriptionController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.description,
        hintText: AppLocalizations.of(context)!.detailedDescriptionOfIssue,
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: 5,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppLocalizations.of(context)!.descriptionRequired;
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(BookBoxIssueReportViewModel viewModel) {
    return TextFormField(
      controller: viewModel.emailController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.email,
        hintText: viewModel.isLoggedIn
            ? AppLocalizations.of(context)!.yourAccountEmailLocked
            : AppLocalizations.of(context)!.yourEmailAddress,
        prefixIcon: const Icon(Icons.email),
        suffixIcon: viewModel.isLoggedIn
            ? const Icon(Icons.lock, color: Colors.grey)
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      enabled: !viewModel.isEmailLocked,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppLocalizations.of(context)!.emailRequired;
        }
        if (!viewModel.isValidEmail(value.trim())) {
          return AppLocalizations.of(context)!.enterValidEmail;
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton(BookBoxIssueReportViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: viewModel.isLoading ? null : () async {
          if (!_formKey.currentState!.validate()) return;

          final result = await viewModel.submitIssue(widget.bookboxId);

          if (mounted) {
            if (result['success']) {
              Get.back(result: result);
            } else {
              CustomSnackbars.error(
                AppLocalizations.of(context)!.error,
                AppLocalizations.of(context)!.failedToReportIssue(result['error']),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: LinoColors.accent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
        ),
        child: viewModel.isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          AppLocalizations.of(context)!.submit,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Kanit',
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(BookBoxIssueReportViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              viewModel.isLoggedIn
                  ? AppLocalizations.of(context)!.emailPrefilledInfo
                  : AppLocalizations.of(context)!.provideEmailInfo,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Kanit',
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}