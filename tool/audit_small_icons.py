"""Check application-owned Flutter pictograms. Run with python3 tool/audit_small_icons.py."""
import re
import sys
from pathlib import Path
from xml.etree import ElementTree

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / 'lib'
ICON_LIBRARY = LIB / 'core/ui_kit/widgets/clay_icon.dart'
ICON_ROOT = ROOT / 'assets/icons'
ART = ICON_ROOT / 'clay'
PLATFORM_ICON = r'\b(?:CupertinoIcons|Icons)\.\w+'
COMPATIBILITY_ART = {
    'compatibility_vector_51', 'compatibility_vector_52',
    'compatibility_heart_left', 'compatibility_heart_right',
}
ART_EXPRESSIONS = {f"'assets/icons/{name}.svg'" for name in COMPATIBILITY_ART}
ART_EXPRESSIONS.update({
    '_compatibilityVector51', '_compatibilityVector52',
    "'assets/background/lunar_calendar_${state.selectedDayStatus.name}.svg'",
})


def main():
    failures = []
    library = ICON_LIBRARY.read_text()
    routes = dict(re.findall(f"({PLATFORM_ICON}): '([^']+)'", library))
    vectors = re.findall(r"'(assets/icons/[^']+\.svg)': Size", library)
    if not routes or not vectors:
        failures.append('Cannot read ClayIcon or ClayAssetIcon mappings')
    for name in set(routes.values()):
        if not (ART / f'{name}.webp').is_file():
            failures.append(f'No platform glyph artwork: {name}')
    sprite_controls = set(re.findall(r"'(\w+)'(?= (?:\|\||=> LotusPose))", library))
    for vector in vectors:
        path = ROOT / vector
        if not path.is_file():
            failures.append(f'Missing vector source {vector}')
        if path.stem not in sprite_controls and not (ART / f'{path.stem}.webp').is_file():
            failures.append(f'No rendering for {vector}')

    used = set()
    for path in sorted(LIB.rglob('*.dart')):
        if path == ICON_LIBRARY:
            continue
        source = path.read_text()
        for name in re.findall(PLATFORM_ICON, source):
            used.add(name)
            if name not in routes:
                failures.append(f'{path.relative_to(ROOT)}: unmapped {name}')
        if re.search(r'\b(?:Icon|ImageIcon)\s*\(', source):
            failures.append(f'{path.relative_to(ROOT)}: raw icon bypasses ClayIcon')
        for entry in re.findall(r'\bSvgPicture\.asset\(\s*([^,\n]+)', source):
            if entry.strip() not in ART_EXPRESSIONS:
                failures.append(f'{path.relative_to(ROOT)}: inspect raw SVG {entry}')

    sources = sorted(ICON_ROOT.rglob('*.svg'))
    for path in sources:
        drawing = ElementTree.parse(path)
        for element in drawing.iter():
            stroke = element.get('stroke')
            if (stroke and stroke != 'none') or re.search(r'stroke\s*:\s*(?!none\b)', element.get('style', '')):
                failures.append(f'{path.relative_to(ROOT)}: stroke-based icon')
                break

    print(f'{len(used)} platform glyphs in application code, {len(routes)} mapped; '
          f'{len(vectors)} vector routes; {len(sources)} SVG sources checked.')
    for failure in failures:
        print(failure, file=sys.stderr)
    return int(bool(failures))


if __name__ == '__main__':
    sys.exit(main())
