// app/lib/views/forum/request_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:Lino_app/vm/forum/request_form_view_model.dart';
import 'package:Lino_app/utils/constants/routes.dart';
import 'package:Lino_app/utils/constants/colors.dart';
import 'package:Lino_app/l10n/app_localizations.dart';

class RequestFormPage extends StatefulWidget {
  final VoidCallback? onRequestCreated;

  const RequestFormPage({this.onRequestCreated, super.key});

  @override
  State<RequestFormPage> createState() => _RequestFormPageState();
}

class _RequestFormPageState extends State<RequestFormPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<RequestFormViewModel>();
      viewModel.resetForm();
      viewModel.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RequestFormViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: const Color.fromRGBO(245, 245, 235, 1),
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.createBookRequest,
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
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header text
                    Text(
                      AppLocalizations.of(context)!.whatBookAreYouLookingFor,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Kanit',
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.searchForBookOrEnterCustomTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Kanit',
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Similar Requests Info (shown when search is locked)
                    if (viewModel.isSearchLocked)
                      _buildSimilarRequestsInfo(viewModel),

                    // Book Title Field with Autocomplete
                    TextFormField(
                      controller: viewModel.titleController,
                      focusNode: viewModel.focusNode,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.bookTitle,
                        helperText: viewModel.isSearchLocked 
                            ? (viewModel.selectedSuggestion != null 
                                ? AppLocalizations.of(context)!.bookSelectedDot
                                : AppLocalizations.of(context)!.customTitleLocked)
                            : AppLocalizations.of(context)!.startTypingToSearch,
                        helperStyle: TextStyle(
                          color: viewModel.isSearchLocked 
                              ? Colors.green.shade700 
                              : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        suffixIcon: viewModel.isLoadingSuggestions 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : viewModel.isSearchLocked
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                        onPressed: viewModel.unlockSearch,
                                        tooltip: AppLocalizations.of(context)!.changeSelection,
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.clear, size: 20, color: Colors.red),
                                        onPressed: viewModel.clearSearch,
                                        tooltip: AppLocalizations.of(context)!.clearSearch,
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  )
                                : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.pleaseTitleRequired;
                        }
                        return null;
                      },
                      onTap: viewModel.onTitleFieldTap,
                      readOnly: viewModel.isSearchLocked,
                    ),
                    
                    // Suggestions List
                    if (viewModel.showSuggestions && (viewModel.suggestions.isNotEmpty || viewModel.isLoadingSuggestions))
                      _buildSuggestionsContainer(viewModel),
                    
                    // Warning for custom titles
                    if (viewModel.isCustomTitle && viewModel.selectedSuggestion == null && !viewModel.showSuggestions)
                      _buildCustomTitleWarning(),
                    
                    const SizedBox(height: 16),
                    
                    // Selected book info
                    if (viewModel.selectedSuggestion != null)
                      _buildSelectedBookInfo(viewModel),
                    
                    // Custom Message Field
                    TextFormField(
                      controller: viewModel.messageController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context)!.customMessageOptional),
                      maxLines: 3,
                      minLines: 1,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Error message
                    if (viewModel.error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                viewModel.error!,
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: viewModel.clearError,
                              child: Text(AppLocalizations.of(context)!.dismissError),
                            ),
                          ],
                        ),
                      ),
                    
                    // Submit Button
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: viewModel.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color.fromRGBO(101, 67, 33, 1),
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () => _submitForm(viewModel),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: LinoColors.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.nextButton,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Kanit',
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionsContainer(RequestFormViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: viewModel.isLoadingSuggestions
          ? Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.searchingForBooks),
                  ],
                ),
              ),
            )
          : viewModel.suggestions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_off, color: Colors.grey, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.noSuggestionsFound,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: viewModel.useCustomTitle,
                        icon: const Icon(Icons.edit, size: 16),
                        label: Text(AppLocalizations.of(context)!.useCustomTitle),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : _buildSuggestionsList(viewModel),
    );
  }

  Widget _buildSuggestionsList(RequestFormViewModel viewModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.selectBookOrUseCustomTitle,
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        // Suggestions list
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: viewModel.suggestions.length + 1, // +1 for custom option
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              if (index == viewModel.suggestions.length) {
                // Custom title option
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.edit, color: Colors.orange),
                    title: Text(
                      AppLocalizations.of(context)!.useCustomTitleOption,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)!.continueWithTitle(viewModel.titleController.text),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    onTap: viewModel.useCustomTitle,
                    dense: true,
                  ),
                );
              }
              
              final suggestion = viewModel.suggestions[index];
              return ListTile(
                leading: const Icon(Icons.book, color: Colors.blue),
                title: Text(
                  suggestion.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.byAuthor(suggestion.author),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                onTap: () => viewModel.selectSuggestion(suggestion),
                dense: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTitleWarning() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.customTitleWarning,
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarRequestsInfo(RequestFormViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          viewModel.isLoadingSimilarRequests
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.info, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: viewModel.isLoadingSimilarRequests
                ? Text(
                    AppLocalizations.of(context)!.checkingForSimilarRequests,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  )
                : viewModel.similarRequestsCount != null
                    ? Text(
                        viewModel.similarRequestsCount == 0
                            ? AppLocalizations.of(context)!.noSimilarBookRequestsFound
                            : AppLocalizations.of(context)!.similarBookRequestsFound(
                                viewModel.similarRequestsCount!,
                                viewModel.similarRequestsCount == 1 ? '' : 's',
                                viewModel.similarRequestsCount == 1 ? 'was' : 'were'
                              ),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.unableToCheckSimilarRequests,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedBookInfo(RequestFormViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectedBookPrefix(viewModel.selectedSuggestion!.title),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.byAuthor(viewModel.selectedSuggestion!.author),
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm(RequestFormViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      Get.toNamed(
        AppRoutes.forum.request.bookboxSelection,
        arguments: {
          'title': viewModel.titleController.text.trim(),
          'customMessage': viewModel.messageController.text.trim(),
          'selectedSuggestion': viewModel.selectedSuggestion,
        },
      );
    }
  }
}
