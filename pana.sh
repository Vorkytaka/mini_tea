#!/bin/bash

# Проверяем переданный пакет
if [ $# -eq 0 ]; then
    echo "Ошибка: Не указано название пакета"
    echo "Использование: $0 package_name"
    exit 1
fi

# Получаем название пакета из аргумента
package_name=$1
package_path="packages/$package_name"

# Проверяем существование папки
if [ ! -d "$package_path" ]; then
    echo "Ошибка: Папка $package_path не существует"
    exit 1
fi

# Копируем папку во временную директорию
mkdir .tmp
mkdir ".tmp/$package_name"
cp -r "$package_path"/* ".tmp/$package_name"

dart pub global activate pana
dart pub global run pana ".tmp/$package_name"

rm -rf .tmp