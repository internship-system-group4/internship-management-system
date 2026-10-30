"""Regression checks: resource generation must not erase newer translations."""
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

BUILDER = Path(__file__).resolve().parents[1] / 'tools/i18n/build-resources.py'

class ResourceGenerationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='uims-i18n-')
        self.root = Path(self.temp.name)
        self.tools = self.root / 'tools/i18n'
        (self.tools / 'strings').mkdir(parents=True)
        self.web = self.root / 'InternshipManagementSystem/InternshipManagementSystem'
        self.web.mkdir(parents=True)
        (self.web / 'InternshipManagementSystem.csproj').write_text('<Project>\n</Project>', encoding='utf-8')
        shutil.copyfile(BUILDER, self.tools / BUILDER.name)

    def tearDown(self):
        self.temp.cleanup()

    def run_builder(self, *args):
        return subprocess.run([sys.executable, '-X', 'utf8', '-I', str(self.tools / BUILDER.name), *args], capture_output=True, text=True, encoding='utf-8')

    def source(self, area, text):
        (self.tools / 'strings' / (area + '.txt')).write_text(text, encoding='utf-8')

    def test_source_cannot_silently_delete_existing_keys_or_partially_write(self):
        self.source('Account', 'Title\nen: Account\nar: الحساب\n')
        self.source('Shared', 'Count\nen: {0} students\nar: عدد الطلاب: {0}\n')
        self.assertEqual(self.run_builder().returncode, 0)
        files = list((self.web / 'App_GlobalResources').glob('*.resx'))
        before = {p: p.read_bytes() for p in files}
        self.source('Account', 'Title\nen: Changed account\nar: الحساب المعدل\n')
        self.source('Shared', 'Other\nen: Other\nar: آخر\n')
        result = self.run_builder()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('refusing to remove', result.stdout)
        self.assertEqual(before, {p: p.read_bytes() for p in files})

    def test_check_detects_stale_generated_text(self):
        self.source('Shared', 'Title\nen: Original\nar: أصلي\n')
        self.assertEqual(self.run_builder().returncode, 0)
        self.source('Shared', 'Title\nen: Updated\nar: معدل\n')
        self.assertNotEqual(self.run_builder('--check').returncode, 0)
        self.assertEqual(self.run_builder().returncode, 0)
        self.assertEqual(self.run_builder('--check').returncode, 0)

    def test_missing_arabic_or_format_argument_fails_without_writing(self):
        self.source('Shared', 'Count\nen: {0} students\n')
        self.assertNotEqual(self.run_builder().returncode, 0)
        self.assertFalse((self.web / 'App_GlobalResources').exists())
        self.source('Shared', 'Count\nen: {0} students\nar: طلاب\n')
        self.assertNotEqual(self.run_builder().returncode, 0)
        self.assertFalse((self.web / 'App_GlobalResources').exists())

if __name__ == '__main__':
    unittest.main()
