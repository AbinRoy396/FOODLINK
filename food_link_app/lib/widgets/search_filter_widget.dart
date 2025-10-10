import 'package:flutter/material.dart';
import '../services/search_filter_service.dart';
import '../models/sort_option.dart';

class SearchFilterWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(List<String>) onStatusFilterChanged;
  final Function(SortOption) onSortChanged;

  const SearchFilterWidget({
    super.key,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onSortChanged,
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedStatuses = [];
  SortOption _selectedSort = SortOption.dateNewest;

  final List<String> _availableStatuses = [
    'Pending',
    'Verified',
    'Allocated',
    'Delivered',
    'Expired',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter & Sort'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._availableStatuses.map((status) {
                  return CheckboxListTile(
                    title: Text(status),
                    value: _selectedStatuses.contains(status),
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          _selectedStatuses.add(status);
                        } else {
                          _selectedStatuses.remove(status);
                        }
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
                const SizedBox(height: 16),
                const Text(
                  'Sort by',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RadioListTile<SortOption>(
                  title: const Text('Date (Newest First)'),
                  value: SortOption.dateNewest,
                  groupValue: _selectedSort,
                  onChanged: (value) {
                    setDialogState(() => _selectedSort = value!);
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<SortOption>(
                  title: const Text('Date (Oldest First)'),
                  value: SortOption.dateOldest,
                  groupValue: _selectedSort,
                  onChanged: (value) {
                    setDialogState(() => _selectedSort = value!);
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<SortOption>(
                  title: const Text('Food Type'),
                  value: SortOption.foodType,
                  groupValue: _selectedSort,
                  onChanged: (value) {
                    setDialogState(() => _selectedSort = value!);
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<SortOption>(
                  title: const Text('Status'),
                  value: SortOption.status,
                  groupValue: _selectedSort,
                  onChanged: (value) {
                    setDialogState(() => _selectedSort = value!);
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedStatuses.clear();
                  _selectedSort = SortOption.dateNewest;
                });
                widget.onStatusFilterChanged([]);
                widget.onSortChanged(SortOption.dateNewest);
                Navigator.pop(context);
              },
              child: const Text('Clear All'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                widget.onStatusFilterChanged(_selectedStatuses);
                widget.onSortChanged(_selectedSort);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search donations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: widget.onSearchChanged,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: _showFilterDialog,
              tooltip: 'Filter & Sort',
            ),
          ),
        ],
      ),
    );
  }
}
