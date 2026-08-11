# NetBits

Калькулятор IP-адресов и подсетей для iOS.

<p align="center">
  <img src="IPCalculator/Resources/Assets.xcassets/IPCalculatorIcon.imageset/IPCalculatorIcon.png" width="96" alt="NetBits icon">
</p>

## Возможности

- Расчёт по IP-адресу и маске/префиксу подсети
- Ввод в формате CIDR одной строкой (`192.168.1.10/24`)
- Бинарное представление адреса и маски
- Копирование любого значения результата долгим нажатием
- Светлая и тёмная тема
- Локализация: English, Русский

## Что считает

Netmask, Wildcard, Network, Broadcast, Hostmin, Hostmax, количество хостов —
плюс бинарный вид адреса и маски.

## Требования

- iOS 15.6+
- Xcode 16+

## Сборка

```bash
open IPCalculator.xcodeproj
```

или из терминала:

```bash
xcodebuild -project IPCalculator.xcodeproj -scheme IPCalculator \
  -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## Архитектура

MVP: `Presenter` держит бизнес-логику и состояние экрана, `View`/`ViewController`
отвечают только за отображение, `Service`/`Formatter`/`Validator` — расчёт и
валидация IP-адресов.

Ветки: `feature/*` → `develop` (rebase, без merge-коммитов) → `master` через
Pull Request.
