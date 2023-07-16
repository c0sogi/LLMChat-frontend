String chatModelNameFormatter(String text) => text.isEmpty
    ? ''
    : text
        .replaceAllMapped(
          RegExp(r'(\d+)_(\d+)'),
          (match) => '${match[1]}.${match[2]}',
        )
        .replaceAll('_', ' ')
        .replaceAll('gpt', 'GPT')
        .split(' ')
        .map((str) => str.contains(RegExp(r'\d+[bk]'))
            ? str.replaceFirst('b', 'B').replaceFirst('k', 'K')
            : str[0].toUpperCase() + str.substring(1))
        .join(' ');
