#!/bin/bash

# Update all ElevatedButton styles to have green background and black text
find lib -type f -name "*.dart" -exec sed -i 's/ElevatedButton\.styleFrom(\([^}]*\)backgroundColor: [^,}]*/ElevatedButton.styleFrom(\1backgroundColor: AppColors.primary/g' {} \;
find lib -type f -name "*.dart" -exec sed -i 's/ElevatedButton\.styleFrom(\([^}]*\)foregroundColor: [^,}]*/ElevatedButton.styleFrom(\1foregroundColor: Colors.black/g' {} \;

# For buttons using ButtonStyle with MaterialStateProperty
find lib -type f -name "*.dart" -exec sed -i 's/ButtonStyle\([^}]*\)backgroundColor: MaterialStateProperty\.all<Color>\([^)]*\)/ButtonStyle\1backgroundColor: MaterialStateProperty.all<Color>(AppColors.primary)/g' {} \;
find lib -type f -name "*.dart" -exec sed -i 's/ButtonStyle\([^}]*\)foregroundColor: MaterialStateProperty\.all<Color>\([^)]*\)/ButtonStyle\1foregroundColor: MaterialStateProperty.all<Color>(Colors.black)/g' {} \;

echo "Button styles updated successfully!"
