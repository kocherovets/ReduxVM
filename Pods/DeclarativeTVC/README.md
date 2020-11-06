
DeclarativeTVC
========

[![CocoaPods Version](https://img.shields.io/cocoapods/v/DeclarativeTVC.svg?style=flat)](http://cocoapods.org/pods/DeclarativeTVC)
[![License](https://img.shields.io/cocoapods/l/Swinject.svg?style=flat)](http://cocoapods.org/pods/DeclarativeTVC)
[![Platforms](https://img.shields.io/badge/platform-iOS-lightgrey.svg)](http://cocoapods.org/pods/DeclarativeTVC)
[![Swift Version](https://img.shields.io/badge/Swift-4.2--5.x-F16D39.svg?style=flat)](https://developer.apple.com/swift)

Declarative UIKit collections

- [Цель проекта](#Цель-проекта)
  * [Пример](#Пример)
  * [Features](#features)
  * [Requirements](#requirements)
  * [Installation](#installation)
    + [CocoaPods](#cocoapods)
- [Как пользоваться](#Как-пользоваться)
  * [Создание view ячеек](#Создание-view-ячеек)
    + [Stryboard](#stryboard)
    + [Xib](#xib)
    + [Программные ячейки](#Программные-ячейки)
  * [Создание view моделей для ячеек](#Создание-view-моделей-для-ячеек)
    + [Выбираемые ячейки](#Выбираемые-ячейки)
    + [Высота ячейки](#Высота-ячейки)
    + [Требования к полям вьюмодели](#Требования-к-полям-вьюмодели)
  * [Секции](#Секции)
  * [Создание таблицы](#Создание-таблицы)
    + [DeclarativeTVC](#declarativetvc-1)
    + [TableDS](#tableds)
  * [Анимации](#Анимации)
  * [Что нужно помнить](#Что-нужно-помнить)
- [Источники](#Источники)

  
# Цель проекта
DeclarativeTVC создана для упрощения работы с UIKit коллекциями переведя взаимодействие с ними к декларативному виду.

## Пример
Простейшая таблица может быть реализована таким образом
```swift
class TVC: DeclarativeTVC {

    var rows: [CellAnyModel] {
         didSet {
            set(rows: rows)
         }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
   
        rows = [
            SimpleCellVM(
                titleText: "1",
                selectCommand: Command { print(1) }
            ),
            SimpleCellVM(
                titleText: "2",
                selectCommand: Command { print(2) }
            )
        ]
    }
}
```

## Features

- Declarative UITableViewController support
- Declarative UITableView without UITableViewController support
- Declarative UICollectionViewController support
- Declarative UICollectionView without UICollectionViewController support
- Storyboard table and collection cells support
- Xib table and collection cells support
- Coded table and collection cells support
- You can mix storyboard, xib and coded cells 
- Animated items update for tables and collections
- Support for fixed and autolayout height for table cells

## Requirements

- iOS 11.0+
- Swift 4.2+

## Installation

DeclarativeTVC is available through [CocoaPods](https://cocoapods.org).

### CocoaPods

To install DeclarativeTVC with CocoaPods, add the following lines to your `Podfile`.

```ruby
pod 'DeclarativeTVC'
```

Then run `pod install` command. For details of the installation and usage of CocoaPods, visit [its official website](https://cocoapods.org).

# Как пользоваться 
Рассмотрим создание простой таблицы с использованием DeclarativeTVC. 
## Создание view ячеек
Первым делом нужно описать ячейки. Библиотека поддерживает работы со всеми типами ячеек: ячейками созданными в storyboard, созданными с использованием xib и программно созданным ячейками. В одной таблице можно смешивать все эти типы ячеек. Рассмотрим примеры для каждого из этих способов.
###  Stryboard
Ячейка должна быть унаследована от класса UITableViewCell или StoryboardTableViewCell.
```swift
class SimpleCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}
// or
class SimpleCell: StoryboardTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}
```
При создании ячейки из сториборда **нужно** в качестве идентификатора ячейки в сториборде указать названиие класса.

<img width="259" alt="Screenshot 2020-02-08 at 22 55 43" src="https://user-images.githubusercontent.com/4235844/74092042-1e496180-4ad0-11ea-84f5-12830c6dfe8f.png">
<img width="260" alt="Screenshot 2020-02-08 at 22 55 53" src="https://user-images.githubusercontent.com/4235844/74092044-1ee1f800-4ad0-11ea-9b3b-23230007a210.png">

###  Xib
Ячейка должна быть унаследована от класса XibTableViewCell.
```swift
class SimpleXibCellVM: XibTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}
```
При создании ячейки из xib **нужно** в качестве имени файла xib использовать имя класса.

<img width="255" alt="Screenshot 2020-02-09 at 10 02 24" src="https://user-images.githubusercontent.com/4235844/74097960-50d07a00-4b23-11ea-9772-648004290c6e.png">

###  Программные ячейки
Ячейка должна быть унаследована от класса CodedTableViewCell.
```swift
class SimpleCodeCellVM: CodedTableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}
```

## Создание view моделей для ячеек
Далее нужно для каждой ячейки создать вьюмодель. Это структура реализующая протокол CellModel.
```swift
struct SimpleCellVM: CellModel {

    let titleText: String?

    func apply(to cell: SimpleCell) {

        cell.titleLabel.text = titleText
    }
}
```
В ней обычно нужно описать поля, из которых потом будет заполняться ячейка, и создать метод `apply(to`.
### Выбираемые ячейки
В модели можно реализовать протокол SelectableCellModel, чтобы ячейку можно было выбрать.
```swift
struct SimpleCellVM: CellModel, SelectableCellModel {

    let titleText: String?
    let selectCommand: Command

    func apply(to cell: SimpleCell) {

        cell.titleLabel.text = titleText
    }
}
```
### Высота ячейки
По умолчанию высота ячейки рассчитывается с помощью auto layout, но можно задать ее и программно.
```swift
struct SimpleCellVM: CellModel, SelectableCellModel {

    let titleText: String?
    let selectCommand: Command

    func apply(to cell: SimpleCell) {

        cell.titleLabel.text = titleText
    }

    var height: CGFloat? { 200 }
}
```
### Требования к полям вьюмодели
Для расчета анимаций обновления таблицы библиотека должна различать ячейки между собой. Для этого протокол CellModel удовлетворяет протоколу Hashable. И все поля во вьюмодели должны также удовлетворять этому протоколу. Простые типы удовлетворяют ему автоматически. Экземпляры Command различаются по своему id. По умолчаниию id пустой и все команды равны друг другу.
```swift
let c1 = Command { print(1) }

let c2 = Command(id: "custom") { print(1) }
```
Если расчета хеша из коробки недостаточно, то можно определить расчет хеша вручную
```swift
struct SimpleCellVM: CellModel, SelectableCellModel {

    let titleText: String?
    let selectCommand: Command

    func apply(to cell: SimpleCell) {

        cell.titleLabel.text = titleText
    }

    var height: CGFloat? { 200 }

    func hash(into hasher: inout Hasher) {
        hasher.combine(titleText)
        hasher.combine("custom")
    }
}
```
## Секции
Заголовки и подвалы реализованы аналогично ячейкам. Строятся они на базе UITableViewCell, а не UIView. 

Регистрировать классы и xib не нужно, библиотека это сделает за вас. Но нужно соблюдать те же правила, что и при создании ячеек.
```swift
class HeaderView: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

}

struct HeaderViewVM: TableHeaderModel {

    let titleText: String?

    func apply(to header: HeaderView) {
        
        header.titleLabel.text = titleText
    }
}
```
## Создание таблицы
Если таблица создается в варианте UITableViewController, то с этой библиотекой нужно использовать DeclarativeTVC.
```swift
open class DeclarativeTVC: UITableViewController {
```
Если в варианте UITableView, то используется TableDS.
```swift
open class TableDS: NSObject, UITableViewDelegate, UITableViewDataSource {
```
### DeclarativeTVC
Класс DeclarativeTVC реализует следующие методы
```swift
open class DeclarativeTVC: UITableViewController {

    open func set(rows: [CellAnyModel], animations: Animations? = nil) {
    open func set(model: TableModel, animations: Animations? = nil) {
    open override func numberOfSections(in tableView: UITableView) -> Int {
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    open override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    open override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
}
```
Соответственно в общем случае он берет на себя ответственность за расчет количества секций и ячеек, созданиие заголовков, подвалов и ячеек, расчет высоты заголовков, подвалов и ячеек, отработку нажатия на ячейку. 

С помощью метода `set(rows: [CellAnyModel]` можно задать для таблицы массив ранее созданных вьюмоделей, что создаст таблицу без секций.

С помощью метода `set(model: TableModel` можно задать для таблицы структуру, где помимо ячеек будут описаны и секциии.
```swift
public struct TableModel: Equatable {

    public var sections: [TableSection]

    public init(sections: [TableSection]) {
    public init(rows: [CellAnyModel]) {

...

public struct TableSection {

    public let header: TableHeaderAnyModel?
    public let footer: TableFooterAnyModel?
    public var rows: [CellAnyModel]

```
Простейшая таблица может быть реализована таким образом
```swift
class TVC: DeclarativeTVC {

    var rows: [CellAnyModel] {
         didSet {
            set(rows: rows)
         }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
   
        rows = [
            SimpleCellVM(
                titleText: "1",
                selectCommand: Command { print(1) }
            ),
            SimpleCellVM(
                titleText: "2",
                selectCommand: Command { print(2) }
            )
        ]
    }
}
```
Вариант с различными типами ячеек
```swift
    func tableRowThreeTypes() -> [CellAnyModel] {
        [
            SimpleCellVM(titleText: "Storyboard cell"),
            SimpleXibCellVM(titleText: "Xib cell"),
            SimpleCodeCellVM(titleText: "Coded cell.")
        ]
    }
```
Вариант с секциямии
```swift
    func tableWithSections() -> [TableSection] {
        [
            TableSection(
                header: nil,
                rows: [
                    SelectAnimationsCellVM(
                        titleText: "Select animations",
                        animationText: state.animationsTitle,
                        selectCommand: Command {
                            self.show(SelectAnimationsVC.self)
                        }),
                    ApplyAnimationsCellVM(
                        titleText: "Apply animations",
                        selectCommand: Command {
                            state.detailType = .tableWithSections2
                            self.reload()
                        })
                ],
                footer: nil),
            TableSection(
                header: HeaderViewVM(titleText: "Header 1"),
                rows: [
                    SimpleCellVM(titleText: "Paragraph 11"),
                    SimpleCellVM(titleText: "Paragraph 12"),
                    SimpleCellVM(titleText: "Paragraph 13"),
                ],
                footer: nil),
            TableSection(
                header: HeaderViewVM(titleText: "Header 2"),
                rows: [
                    SimpleCellVM(titleText: "Paragraph 21"),
                    SimpleCellVM(titleText: "Paragraph 22"),
                    SimpleCellVM(titleText: "Paragraph 23")
                ],
                footer: nil),
        ]
    }
```

### TableDS
Использование TableDS отличается от использования DeclarativeTVC тем, что нужно еще при задании вьюмоделей задавать и tableView.
```swift
open class TableDS: NSObject, UITableViewDelegate, UITableViewDataSource {

    open func set(tableView: UITableView?, rows: [CellAnyModel], animations: DeclarativeTVC.Animations? = nil) {
    open func set(tableView: UITableView?, model: TableModel, animations: DeclarativeTVC.Animations? = nil) {
```
**Нельзя** применять TableDS к tableView из UITableViewController. В этом случае используйте DeclarativeTVC.
## Анимации
При обновлениии данных таблицы можно задать анимацию для этого обновления. 
```swift
public extension DeclarativeTVC {

    struct Animations: Equatable {
        let deleteSectionsAnimation: UITableView.RowAnimation
        let insertSectionsAnimation: UITableView.RowAnimation
        let reloadSectionsAnimation: UITableView.RowAnimation
        let deleteRowsAnimation: UITableView.RowAnimation
        let insertRowsAnimation: UITableView.RowAnimation
        let reloadRowsAnimation: UITableView.RowAnimation
```
По умолчанию обновление происходит без анимации.
```swift
    open func set(rows: [CellAnyModel], animations: DeclarativeTVC.Animations? = nil) {
```
В библиотеке есть одна предопределенная анимация, остальные делаются подобным образом.
```swift
    static let fadeAnimations = Animations(deleteSectionsAnimation: .fade,
                                           insertSectionsAnimation: .fade,
                                           reloadSectionsAnimation: .fade,
                                           deleteRowsAnimation: .fade,
                                           insertRowsAnimation: .fade,
                                           reloadRowsAnimation: .fade)

...

    set(rows: rows, animations: DeclarativeTVC.fadeAnimations)

```
## Что нужно помнить
* При создании ячейки из сториборда **нужно** в качестве идентификатора ячейки в сториборде указать названиие класса.
* При создании ячейки из xib **нужно** в качестве имени файла xib использовать имя класса.
* При использовании анимации для обновления таблицы хеши ячеек **должны** быть разные. Иначе приложение вылетит.
* При использовании анимации ячейки с одинаковыми хешами в старой и новой версии таблицы не обновляются. Это можно использовать, например, для редактирования UITextView и обновлениия остальной таблицы во время редактирования без потери фокуса на текстовом поле, если сохранять одинаковым хэш ячейки редактирования.
* При расчете высоты ячеек и заголовков посредством auto layout нужно в сториборде соответсвенно настроить параметры расчета высоты.
* **Нельзя** применять TableDS к tableView из UITableViewController. В этом случае используйте DeclarativeTVC.
* Если анимации не используются, то происходит обновление всех ячеек таблицы вне зависимости от их хэша. Под капотом вызывается tableView.reloadData()
* Библиотека не требует, чтобы вьюмодели ячеек были структурами, но при разработке это неявно подразумевалось и мною вьюмодели никогда не делались классами. На мой взгляд это приводит к более проблемному коду.
# Источники
Создание библиотеки было вдохновлено [выступлением](https://www.youtube.com/watch?v=Ge73dsgXf_M) [Alexander Zimin](https://github.com/azimin) 
