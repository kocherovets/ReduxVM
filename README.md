- [Описание](#Описание)
- [Плюсы и минусы](#Плюсы-и-минусы)
- [Как пользоваться](#Как-пользоваться)
  * [State](#State)
  * [Store](#Store)
  * [DI](#DI)
  * [Action](#Action)
    + [Reducer](#Reducer)
  * [Middleware](#Middleware)
  * [VC (View)](#VC)
    + [Props](#Props)
    + [Presenter](#Presenter)
  * [TVC (View)](#TVC)
    + [Props](#tvc-props)
    + [Presenter](#tvc-presenter)
  * [Service](#Service)
  * [Side Effect](#Side-Effect)
- [Use Cases](#Use-Cases)
- [Источники](#Источники)
# Описание
ReduxVM - это библиотека для построения iOS приложения по архитектуре, структурная схема которой выглядит следующим образом:

<img width="700" alt="ReduxVM" src="https://user-images.githubusercontent.com/4235844/76704604-273edb80-66eb-11ea-9edd-3e3a19f4aa92.jpg">

Стрелками изображено движение данных между модулями системы. Как видно ReduxVM реализует однонаправленную архитектуру. Единственное место, где это правило нарушается - это сайдэффекты. Поскольку данные могут передаваться только в одном направлении, гораздо проще визуально следовать за кодом и выявлять любые проблемы в приложении.

Вся схема разделена на две части - Background и Foreground. ReduxVM автоматически реализует это разделение. В соответствии с названием эти части выполняются либо на основном, либо в фоновом потоках. Так как в основном потоке выполняется только модуль View, то ReduxVM из коробки исключает блокирование UI работой других модулей программы. Нужно отметить, что весь блок Background работает в одном и том же потоке синхронно. Но каждый Action добавляет новую задачу в этом поток, так что все Actions выполняются один за другим не перекрываясь.

Перечислим все модули и дадим их краткое описание.
- **State** хранит текущее состояние приложения и позволяет на себя подписаться чтобы отслеживать изменения. В ReduxVM к модулю State подключаются модули Presenter и Service, но можно и непосредственно подписаться на State, если это понадобится. State представляет собой swift структуру, которая обычно состоит из нескольких подструктур описывающих разные разделы бизнес логики. 
- **Action** инициирует изменение состояния в приложении. Представляет собой swift структуру. Его назначение просто через свой тип и возможные поля хранить информацию о текущем действии. Action из View переводится в фоновый поток и далее обрабатывается уже в нем. Важно понимать, что изменить State можно только с помощью Action. Только у Action есть доступ к State на запись.
- **Reducer** представляет собой чистую синхронную функцию меняющую State. В ReduxVM Reducer программно является методом структуры Action принимающую на вход текущий State и на выходе выдающую новый State, который перезаписывает текущий. Строго говоря State передается как inout параметр. Тут важно отметить, что это именно чистая функция и кроме как поменять одну структуру на другую - старый стейт на новый, ей запрещено что-то делать. Reducer всегда срабатывает один раз после регистрации в системе нового Action.
- **Presenter** представляет собой связующее звено между State и UI. При создании View также создается относящийся к нему Presenter. Presenter при создании подписывается на State и далее получает от него уведомления, когда State изменяется. Существуют несколько механизмов по оптимизации лишних вызовов Presenter из State. Задачей Presenter является трансляция данных из State в Props для того View, к которому он привязан.
- **Props** представляет собой структуру, содержащую простую информацию для отображения в UI посредством модуля View. К такой информации относятся строки, числа, даты и другие примитивные типы данных. Поля описывают именно структуру того View, к которому относится Props, причем без ссылок на предметную область и бизнес логику. Также в Props могут содержаться триггеры с Action. Props не знает, что это за Action и зачем они нужны, он просто их хранит. 
View является наследником UIViewController и должен просто отображать передаваемую ему в Props информацию. Также он знает, например, что при нажатии на кнопку, он должен запустить определенный Action из Props, но как и Props не имеет представления что именно он запускает. Важно отметить, что View не должен знать вообще ничего про бизнес логику и если и хранить какую-то информацию о состоянии приложения, то это должна быть информация касающаяся исключительно UI. Например, состояние анимации в данном UIViewController.
- **Service** представляет собой подписчиков к Store не связанных напрямую с UI, то есть код Service выполняется в фоновом потоке. Service является управляющей сущностью для некоторого набора SideEffects обычно логически связанных с точки зрения программы. Например, это может быть сервис для работы с сетью. При изменении State каждый Service опрашивает свои SideEffects узнавая должны ли они запуститься и если должны, то запускает.
- **SideEffect** состоит из двух частей. Первая - это проверка срабатывания на основании текущего состояния State. Вторая - некоторое действие как реакция на изменение State. SideEffect не имеет доступа к State на запись, поэтому после какой-то работы, например, получения данных из сети, SideEffect регистрирует в системе Action, который уже изменит State.

ReduxVM для всех подписчиков на State предоставляется не только текущую версию State, а специальный объект Box. В котором содержится текущее состояние State, предыдущее состояние State, Action приведший к этому изменению и набор вспомогательных методов для упрощения анализа текущей ситуации.

# Плюсы и минусы

Плюсы:

- Большое количество стандартизированных модулей позволяют после обучения легко локализовать место требующее внимания.
- Однонаправленный поток данных: приложения, реализующие многонаправленный поток данных, могут быть очень трудными для чтения и отладки. Одно изменение может привести к цепочке событий, которые отправляют данные по всему приложению. Однонаправленный поток более предсказуем и значительно снижает когнитивную нагрузку, необходимую для чтения кода.
- В настоящее время нет хорошего способа обработки Cross CuttingConcern в Swift. В ReduxVM, вы получите его бесплатно. Вы можете решать различные задачи, используя сервисы. Это позволяет легко справиться с такими задачами как ведением журнала или статистикой.
- Тестирование: ReduxVM создавалась с целью, помимо всего прочего, быть очень простой для написания тестов. Reducers содержат код, необходимый для тестирования и они являются чистыми функциями. Чистые функции всегда дают один и тот же результат для того же входа, не полагаются на состояние приложения и не имеют побочных эффектов. 
- В ReduxVM модуль Presenter при стандартной, чего обычно достаточно, реализации также представляет собой одну или две чистых функции, что делает тестирование очень простым. Модуль Props тестирования не требует. 
- Модуль View зависит только от своих Props, потому просто создавая тестовые заполнения структуры Props, можно рендерить View с любыми нужными данными и проверять его работу, например, сравнивая получившиеся скриншоты с образцом.
- Часть SideEffect отвечающая за проверку срабатываемости также является чистой функцией.
Тестировании оставшейся части SideEffect можно также радикально упростить, если следовать подходу изложенному в [докладе](https://www.youtube.com/watch?v=bhEn-VOH0q0&t=1975s). ReduxVM поддерживаем его естественным образом.
- Отладка: при условии, что состояние определено в одной структуре и однонаправленном потоке, отладка намного проще. 
- Из-за того, что практически вся активность в системе запускается через Action, а Action проходит по одному и тому же пути, можно выводить в лог практически всю информацию по работе приложения, что и делается, что также очень сильно помогает в отладке.
- Можно организовать сохранение всех Action примененных к State, тогда по первоначальному State и этой истории можно восстановить весь жизненный цикл конкретной программной сессии, что может быть очень полезным для отладки.
- Также можно упростить разработку, сформировав тестовое заполнение Store нужными данными и показав сразу при старте нужный экран приложения. Так как работа экрана зависит только от связки State -> Presenter -> Props -> View, то можно сразу увидеть как он будет выглядеть минуя возможно долгий путь к этому экрану обычным способом.
- Хорошая справляется с ростом приложения. Так как состояние всего приложения хранится в древовидной структуре, то просто добавляя туда нужные подструктуры можно расширять модель данных поддерживаемых приложением.
- Это также ведет к одному из возможных решения проблемы поддержки нескольких приложений с базовой функциональностью. Можно остаться в рамках одного проекта и завести несколько таргетов, который в том числе будут просто предоставлять разный исходный код по сбору State из подструктур. В каждом подпроекте будут только необходимые для него данные.
- Reducer-ы содержат понятное описание изменений состояния приложения и прочитав их, можно получить достаточно полное представление, как оно вообще работает.
- State является единым источником правды для всего приложения. Поэтому исключены баги, когда приложение в разных местах отображая логически одни и те же данные, на деле показывает разные данные. Любые изменения в State автоматически транслируются на все активные View. Что особенно актуально для приложений связанных с безопасностью и финансами.
- ReduxVM при всей своей мощи достаточно простая в освоении архитектура и требует на полное освоение с помощью знакомого с ней человека около дня чистого времени.
- ReduxVM позволяет отделить бизнес логику от сайд эффектов.
- Реализация State выполнена на обычных структурах Swift, которые являются немутабельными, поэтому не надо опасаться случайных изменений в Store не прошедших путь заданный архитектурой.
- Платформонезависимость: все элементы RedSwift — Stores, Reducers и Actions — независимы от платформы. Их можно легко использовать повторно для iOS, macOS или tvOS, разделять бизнеслогику между приложениями на iPhone и iPad.

Минусы:

Минусы больше относятся к чистой Redux архитектуре. Поэтому рядом с минусом сразу указывается решение проблемы в рамках ReduxVM.

- Большая модульность ведет к большому количеству файлов. Поэтому даже несложные изменения могут потребовать редактирования сразу в нескольких местах. Что требует полного владения архитектурой. _В ReduxVM есть шаблоны, которые генерируют автоматически все нужные файлы и связи между ними для ViewController._
- Так как State может быть большим, то нужно быть аккуратным с написанием Reducer, чтобы они не занимали много времени. _В ReduxVM эта часть кода работает в фоновом потоке, поэтому влияние на UI снижается._
- Разработка модели данных является более сложной, чем в других подходах. В тоже время после того как модель разработана, становится гораздо понятнее работа со всем приложением.
- Подход мотивирует пользоваться декларативным стилем программирования. _Подавляющее большинство проблем вытекающих из этого решены в ReduxVM введением Presenter и Props, а также написанием сервисных классов для таблиц и коллекций работающих в декларативном стиле. В ReduxVM используется библиотека DeclarativeTVC для работы со списочными интерфейсами._

# Как пользоваться
Примеры кода взяты из проекта [MoviesDB](https://github.com/kocherovets/MoviesDB) созданного специально для демонстрации работы ReduxVM
## State
Создание проекта начинается с создания State. Это структура помеченная протоколом StateType.
```swift
struct MoviesState: StateType {

    enum Category: Int {
        case nowPlaying = 0
        case upcoming = 1
        case trending = 2
        case popular = 3
    }
    var selectedCategory = Category.nowPlaying

    var isNowPlayingLoading = false
    var nowPlayingPage: Int = 0
    var nowPlayingMovies = [ServerModels.Movie]()
    
    ...
}
```
Таких стейтов в проекте может быть много, каждый из которых отвечает за какую-то часть приложения. Все они сгруппированы в кореневом стейте, удовлетворяющего протоколу RootStateType.
```swift
struct State: RootStateType {

    var moviesState = MoviesState()
    
    ...
}
```
Как видно, поля в стейтах создаются как ```var```, чтобы можно было их редактировать.
## Store
Основной менеджмент State программы осуществляет класс Store. 
```swift
open class Store<State: RootStateType>: StoreTrunk {

...

    public required init(
        state: State?,
        queue: DispatchQueue,
        middleware: [Middleware] = [],
        statedMiddleware: [StatedMiddleware<State>] = []
    )
```
Здесь state - это наш корневой стейт; queue - это фоновая очередь, в которой работает вся система (синяя область на рисунке); middleware - это набор Middleware. 
## DI
Библиотека предпологает использование использование какой-то реализации Dependency Injection для связывания своих компонент. В примерах используется библиотека DITranquillity, но можно пользоваться и любой другой, например, Swinject.
Пример инициализациии связей библиотеки может выглядеть следующим образом.
```swift
public class AppFramework: DIFramework {
    public static func load(container: DIContainer) {

        container.register (State.init)
            .lifetime(.single)

        container.register { DispatchQueue(label: "queueTitle", qos: .userInteractive) }
            .as(DispatchQueue.self, name: "storeQueue")
            .lifetime(.single)

        container.register {
            Store<State>(state: $0,
                         queue: $1,
                         middleware: [
                           LoggingMiddleware(loggingExcludedActions: [])
                         ])
        }
            .lifetime(.single)

        container.register (APIService.init)
            .lifetime(.single)

        container.registerStoryboard(name: "Main").lifetime(.single)
        container.registerStoryboard(name: "Movies").lifetime(.single)
        container.registerStoryboard(name: "Movie").lifetime(.single)

        container.append(part: MoviesVCModule.DI.self)
        container.append(part: MoviesTVCModule.DI.self)
        container.append(part: Movies2TVCModule.DI.self)
        container.append(part: MovieVCModule.DI.self)
    }
}

let container = DIContainer()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        DISetting.Log.level = .warning
        
        container.append(framework: AppFramework.self)

        if !container.validate() {
            fatalError()
        }

        container.initializeSingletonObjects()

        return true
    }
 ```
 ## Action
 Далее можно создать Actions для изменения State
 ```swift
 extension MoviesState {

    struct LoadAction: Action {

        let category: Category

        func updateState(_ state: inout State) {
            switch category {
            case .nowPlaying:
                state.moviesState.isNowPlayingLoading = true
            case .upcoming:
                state.moviesState.isUpcomingLoading = true
            case .trending:
                state.moviesState.isTrendingLoading = true
            case .popular:
                state.moviesState.isPopularLoading = true
            }
        }
    }
    
    ...
 ```
 Программная реализация Action является структурой, поля которой являются параметрами задающими изменения, и функции ```func updateState(_ state: inout State)```, куда передается корневой стейт по ссылке. 
### Reducer
В функции updateState собственно и происходит обновление стейта. То есть в терминологии редакса - эта функция является редьюсером.
## Middleware
Прежде чем стейт обновится Action обрабатывается объектами Middleware, которые не могут менять стейт. Они могут использоваться, например, для логирования. Библиотека поддерживает два типа Middleware, один получает на вход только Action, другой кроме Action получает также текущий стейт.
```swift
open class Middleware {

    public func on(action: Dispatchable,
                   file: String,
                   function: String,
                   line: Int
    ) {
        
    }
}

open class StatedMiddleware<State: RootStateType> {

    public func on(action: Dispatchable,
                   state: State,
                   file: String,
                   function: String,
                   line: Int
    ) {

    }
}
```
В библиотеке есть реализация по умолачанию LoggingMiddleware. По умолчаниию все Action в системе логируются, для некоторых из них бывает удобно отключить логирование, в loggingExcludedActions перечисляются такие Action.
```swift
public class LoggingMiddleware: Middleware {

    private var loggingExcludedActions = [Dispatchable.Type]()

    public required init(loggingExcludedActions: [Dispatchable.Type]) {

        self.loggingExcludedActions = loggingExcludedActions
    }

    override public func on(action: Dispatchable,
                            file: String,
                            function: String,
                            line: Int) {

        if loggingExcludedActions.first(where: { $0 == type(of: action) }) == nil {

            let log =
                """
                 ---ACTION---
                 \(action)
                 file: \(file):\(line)
                 function: \(function)
                 .
                 """
            print(log)
        }

    }
}
```
## VC
Библиотека содержит два класса: VC и TVC, заменяющие соответсвенно UIViewConttroler и UITableViewController.
```swift
class MoviesVC: VC, PropsReceiver {

    typealias Props = MoviesVCModule.Props

    override func render() {

        guard let props = props else { return }

        navigationItem.title = props.title

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: props.rightBarButtonImageName),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(changeMode))

        if props.showsGeneralView && containerView1.isHidden {
            setupTables(showsGeneralView: true)
        } else if !props.showsGeneralView && containerView2.isHidden {
            setupTables(showsGeneralView: false)
        }
    }
    
    @IBAction func changeMode() {
        props?.changeViewModeCommand.perform()
    }
    ...
```

Здесь видны все части, которые относятся к ReduxVM. 

```class MoviesVC: VC, PropsReceiver {``` - пользовательский вьюконтроллер, унаследованный от VC также должен удовлетворять протоколу PropsReceiver.

```typealias Props = MoviesVCModule.Props``` - нужно указать конкретную структуру MoviesVCModule.Props как пропсы для данного вьюконтроллера.

```override func render() {``` - нужно реализовать функцю render, которая вызывается при изменениии значений из Props. В ней элементам интерфейса настраиваются в соответствии со значениями пропсов.

```props?.changeViewModeCommand.perform()``` - в методах реакции на события в интерфейсе можно вызывать команды из пропсов.

Полную реализацию можно посмотреть по [ссылке](https://github.com/kocherovets/MoviesDB/blob/master/MoviesDB/UI/Movies/MoviesVC.swift)

### Props

Структура пропсов для MoviesVC выглядит так
```swift
    struct Props: Properties, Equatable {
        let title: String
        let rightBarButtonImageName: String
        let showsGeneralView: Bool
        let changeViewModeCommand: Command
    }
 ```
 
### Presenter
 
С каждым VC связан свой Presenter, который подписывается на изменения в State и формирует новые пропсы для VC. 
```swift
    class Presenter: PresenterBase<State, Props, ViewController> {

        override func reaction(for box: StateBox<State>) -> ReactionToState {
            return .props
        }

        override func props(for box: StateBox<State>, trunk: Trunk) -> Props? {

            let title: String
            let rightBarButtonImageName: String
            if box.state.moviesState.viewMode == .general {
                switch box.state.moviesState.selectedCategory {
                case .nowPlaying:
                    title = "Now Plaing"
                case .upcoming:
                    title = "Upcoming"
                case .trending:
                    title = "Trending"
                case .popular:
                    title = "Popular"
                }
                rightBarButtonImageName = "rectangle.3.offgrid.fill"
            } else {
                title = "Movies"
                rightBarButtonImageName = "rectangle.grid.1x2"
            }

            return Props(
                title: title,
                rightBarButtonImageName: rightBarButtonImageName,
                showsGeneralView: box.state.moviesState.viewMode == .general,
                changeViewModeCommand: Command { trunk.dispatch(MoviesState.ChangeViewModeAction()) }
            )
        }
    }
```

В презентере нужно реализовать как минимум функцию ```override func props(for box: StateBox<State>, trunk: Trunk) -> Props? {```. Ей на вход передается объект StateBox, в котором хранится новый стейт, предыдущий стейт и Action приведший к изменению стейта. Также передается объект Trunk, являющийся шиной, куда посылаются все новые Action с помощью функциии dispatch. На выходе функция ```props(for``` формирует новую структуру Props для VC. 

С помощью функции ```override func reaction(for box: StateBox<State>) -> ReactionToState {``` можно настроить поведение презентера. По умолчанию она задает поведение, когда презентер пересчитывает новые пропсы и отдает их VC. Но также на основаниии информациии из StateBox он может принять решение проигнорировать изменениия из стейта и ничего не делать.

Полную реализацию, в том числе реализацию DI, можно посмотреть по [ссылке](https://github.com/kocherovets/MoviesDB/blob/master/MoviesDB/UI/Movies/MoviesVC.swift)

## TVC
Реализация табличных интерфейсов полагается на библиотеку [DeclarativeTVC](https://github.com/kocherovets/DeclarativeTVC) и если нужно только отобразить таблицу и реагировать на нажатия на ячейки, то достаточно написать
```swift
class MoviesTVC: TVC, PropsReceiver {

    typealias Props = TableProps

}
```
Дополнтельно нужно реализовывать функциональность типа удаления ячейки по свайпу. Для этого достаточно переопределить соответствующие методы, так как TVC является наследником UITableViewController.

<a name="tvc-props"></a>
### Props
Пропсы для TVC в должны удовлетворять протоколу TableProperties и есть реализация по умолчанию TableProps
```swift
public struct TableProps: TableProperties, Equatable {

    public var tableModel: TableModel
    public var animations: DeclarativeTVC.Animations?
}
```
где можно задать модели ячеек, заголовков и подвалов, а также анимацию обновления таблицы. Подробнее смотрите в описаниии библииотеки [DeclarativeTVC](https://github.com/kocherovets/DeclarativeTVC)

<a name="tvc-presenter"></a>
### Presenter
Презентер для MoviesTVC
```swift
 class Presenter: PresenterBase<State, TableProps, ViewController> {

        override func onInit(state: State, trunk: Trunk) {

            switch state.moviesState.selectedCategory {
            case .nowPlaying:
                if state.moviesState.nowPlayingMovies.count == 0 {
                    trunk.dispatch(MoviesState.LoadAction(category: .nowPlaying))
                }
             
            ... 
              
            }
        }

        override func reaction(for box: StateBox<State>) -> ReactionToState {

            if !box.isNew(keyPath: \.moviesState.selectedCategoryMovies) {
                return .none
            }

            return .props
        }

        override func props(for box: StateBox<State>, trunk: Trunk) -> TableProps? {

            var rows = [CellAnyModel]()

            rows.append(
                SegmentedCellVM(
                    selectedIndex: box.state.moviesState.selectedCategory.rawValue,
                    
                    ...

                    })
            )

            if box.state.moviesState.selectedCategoryMovies.count > 0 {

                for movie in box.state.moviesState.selectedCategoryMovies {
                    rows.append(
                        MovieCellVM(title: movie.title,
                        
                        ...
                    )
                }
            } else {
                for _ in 0 ..< 20 {
                    rows.append(
                        MovieStubCellVM()
                    )
                }
            }
            return TableProps(tableModel: TableModel(rows: rows))
        }
    }
```

Здесь видно использование еще одной возможности презентера.

Функция ```override func onInit(state: State, trunk: Trunk) {``` вызывается при создани презентера. Есть также функция ```open func onDeinit(state: State, trunk: Trunk) { }``` вызывающая при уничтожении презентера. Нужно отметить, что жизненным циклом презентера управляет ассоциированный с ним VC или TVC. 
## Service
При создании сервиса нужно перечислить сайдэффекты, которые он обслуживает. 
```swift
class APIService: Service<State> {

    let api = UnauthorizedAPI.self

    override var sideEffects: [AnySideEffect] {
        [
            LoadNowPlayingMoviesSE(),
            LoadUpcomingMoviesSE(),
            LoadTrendingMoviesSE(),
            LoadPopularMoviesSE(),
            
            CreateDetailsSE(),
        ]
    }

    deinit {
    }
}
```
По сути задачей сервиса является подписка на обновления стейта и распространение этой информации для своих сайдэффектов. Также он может переопределить метод ```open func onInit() {```, который вызывается при создании сервиса.
## Side Effect
Реализация сайдэффекта может выглядеть так
```swift
extension APIService {

    fileprivate struct LoadNowPlayingMoviesSE: SideEffect {

        func condition(box: StateBox<State>) -> Bool {

            if let action = box.lastAction as? MoviesState.LoadAction,
                action.category == .nowPlaying,
                box.isNew(keyPath: \.moviesState.isNowPlayingLoading) {

                return true
            }
            return false
        }

        func execute(box: StateBox<State>, trunk: Trunk, service: APIService) {

            _ = service.api.request(target: UnauthorizedAPI.nowPlaying(page: box.state.moviesState.nowPlayingPage + 1))
            {
                (result: Result<ServerModels.NowPlaying, Error>) in

                switch result {
                case .success(let data):
                    trunk.dispatch(MoviesState.AppendNowPlayingMoviesAction(movies: data.results))
                case .failure:
                    trunk.dispatch(MoviesState.ErrorLoadingAction(category: .nowPlaying))
                }
            }
        }
    }
    
    ...
```
Как видно она состоит из двух функций. 

```func condition(box: StateBox<State>) -> Bool {``` - это условие срабатывания сайдэффекта, на вход подается уже известный объект StateBox, на выходе сайдэффект нужно ли его запускать или нет. 

```func execute(box: StateBox<State>, trunk: Trunk, service: APIService) {``` - это собственно рабочая часть сайдэффекта. На вход помимо StateBox передается trunk, чтобы сайдэффект мог по результатам своей деятельности поменять стейт, а также ссылка на сервис, к которому принадлежит этот сайдэффект. 

В данном примере видно, что StateBox содержит вспомогательную функцию isNew, которая проверяет поменялось ли значение по заданному keyPath.
# Use Cases
В этом разделе будут приведены примеры, как в рамках ReduxVM предполагается выполнять те или иные сценарии.
# Источники
Создание библиотеки было вдохновлено выступлениями [Alexey Demedetskiy](https://github.com/AlexeyDemedetskiy), в частности [докладом](https://youtu.be/vcbd3ugM82U)

На реализацию сайдэффектов повлиял [доклад](https://youtu.be/bhEn-VOH0q0)  [Vitalii Malakhovskiy](https://github.com/vmalakhovskiy)

Redux часть библиотеки реализована в библиотеке [RedSwift](https://github.com/kocherovets/RedSwift), которая в свою очередь является переработанной версией [ReSwift](https://github.com/ReSwift/ReSwift) с программным интефейсом в стиле [katana-swift](https://github.com/BendingSpoons/katana-swift)

Создание библиотеки [DeclarativeTVC](https://github.com/kocherovets/DeclarativeTVC) было вдохновлено [выступлением](https://youtu.be/Ge73dsgXf_M) [Alexander Zimin](https://github.com/azimin) 
