#!/bin/bash

# Find all Dart files with ElevatedButton and update them
find lib -type f -name "*.dart" -exec sed -i '' -E 's/ElevatedButton\.styleFrom\(/ElevatedButton.styleFrom(\n                      backgroundColor: Colors.green,\n                      foregroundColor: Colors.black,\n                      minimumSize: const Size(double.infinity, 56),\n                      shape: RoundedRectangleBorder(\n                        borderRadius: BorderRadius.circular(8),\n                      ),\n                      elevation: 0,/g' {} \;

echo "All buttons have been updated with green background and black text."
