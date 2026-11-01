String releaseBranchFor(String versionName) =>
    switch (RegExp(r'^(\d+)\.(\d+)\.\d+$').firstMatch(versionName)) {
      final match? => '${match[1]}.${match[2]}.0',
      null => versionName,
    };
