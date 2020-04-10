import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo: Draggable Scrollable Animation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DemoItemsDraggableScrollableDetailsPage(
        title: 'Animation with ScrollableDraggableSheet demo',
      ),
    );
  }
}

class DemoItemsDraggableScrollableDetailsPage extends StatefulWidget {
  DemoItemsDraggableScrollableDetailsPage({Key key, this.title})
      : super(key: key);

  final String title;

  @override
  _DemoItemsDraggableScrollableDetailsPageState createState() =>
      _DemoItemsDraggableScrollableDetailsPageState();
}

class _DemoItemsDraggableScrollableDetailsPageState
    extends State<DemoItemsDraggableScrollableDetailsPage> {
  final double defaultImageAspectRatio = 2;
  final double defaultPadding = 9;
  final ValueNotifier<ItemModel> _selectedItem = ValueNotifier(null);

  List<ItemModel> _items;

  @override
  void initState() {
    super.initState();
    prepareItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: <Widget>[
          _buildMainContent(context),
          _buildToggleButtons(context),
          _buildAnimatedItemDetails(context),
        ],
      ),
    );
  }

  void prepareItems() {
    _items = [
      ItemModel(
        imageUrl:
            "https://natgeo.imgix.net/factsheets/thumbnails/InternationalCheetahDay2.jpg?auto=compress,format&w=1024&h=560&fit=crop",
        content: """
        Small test content
        
        Small test content
        
        Small test content
        
        Small test content
        
        Small test content
        """,
      ),
      ItemModel(
        imageUrl:
            "https://imagesvc.meredithcorp.io/v3/mm/image?url=https%3A%2F%2Fstatic.onecms.io%2Fwp-content%2Fuploads%2Fsites%2F28%2F2020%2F03%2Fatlanta-zoo-panda-cam-ZOOCAMS0320.jpg",
        content: """Medium long content Medium long content Medium long content 
         Medium long content Medium long content Medium long content
         
         Medium long content Medium long content Medium long content
         
         Medium long content Medium long content Medium long content
         """,
      ),
      ItemModel(
        imageUrl:
            "https://cdn.theatlantic.com/thumbor/EX3oAJ4KOKzh-HCi8jiy7qB-HK0=/0x249:3722x2187/960x500/media/img/mt/2018/10/GettyImages_939413302/original.jpg",
        content:
            """Very long content Very long content Very long content Very long content Very long content Very long content Very long content Very long content Very long content Very long content
            
            Very long content Very long content Very long content Very long content Very long content Very long content Very long content Very long content Very long content Very long content 
            
            Very long content Very long content Very long content Very long content Very long content Very long content Very long content Very long content Very long content Very long content 
            
            Very long content Very long content Very long content Very long content Very long content Very long content Very long content Very long content Very long content Very long content 
            """,
      ),
    ];
  }

  Widget _buildMainContent(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
      child: Center(
        child: Text(
          'Background Content here placed',
        ),
      ),
    );
  }

  Widget _buildAnimatedItemDetails(context) {
    return Align(
      alignment: Alignment.bottomCenter,
      //Используем ValueListenableBuilder, чтобы при изменении _selectedItem обновлялся не весь экран, а только карточка с информацией о нем
      child: ValueListenableBuilder(
        valueListenable: _selectedItem,
        builder: (context, item, child) {
          return AnimatedSwitcher(
            //AnimatedSwitcher сам выполняет анимацию, если child вдруг изменился
            child: _buildDraggableScrollableItemDetails(context),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            duration: Duration(milliseconds: 500),
            reverseDuration: Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              //Непосрественно виджет "анимации", который выполняет показ нового child'а, и скрытие старого
              return SizeTransition(
                axisAlignment: -1,
                sizeFactor: animation,
                child: FadeTransition(
                  child: child,
                  opacity: animation,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDraggableScrollableItemDetails(BuildContext context) {
    if (_selectedItem.value == null) {
      return SizedBox.shrink(
        key: ValueKey(null),
      );
    }
    return LayoutBuilder(
      //key - ключевой момент для работы AnimatedSwitcher
      key: ValueKey(_selectedItem.value),
      builder: (context, constraints) {
        var height = defaultPadding +
            ((constraints.maxWidth - 2 * defaultPadding) /
                defaultImageAspectRatio) +
            defaultPadding;
        var initialChildSize = height / constraints.maxHeight;
        //Отображаем виджет, который позволяет "вытягивать" и "скролить" контент в карточке
        return DraggableScrollableSheet(
          //Настройки были просчитаны заранее. С учетом того, чтобы при открытии DraggableScrollableSheet
          //Отображалась картинка из карточки + учет горизонтальных и вертикальных отступов
          initialChildSize: initialChildSize,
          minChildSize: initialChildSize,
          maxChildSize: initialChildSize * 1.5,
          builder: (context, scrollController) {
            return _buildItemDetails(context, scrollController);
          },
        );
      },
    );
  }

  Widget _buildItemDetails(
      BuildContext context, ScrollController scrollController) {
    return SingleChildScrollView(
      //Ключевой момент: строим карточку с учетом переданного scrollController от DraggableScrollableSheet
      //Пока карточка "вытянута" не на максимальный размер, DraggableScrollableSheet сам обрабатывает drag
      //Как только DraggableScrollableSheet больше не может тянуться выше, то дальше начинает работать обычный SingleChildScrollView
      //При этом свзь между ними проходит через работу с единым scrollController
      controller: scrollController,
      child: Container(
        color: Colors.blue,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (_selectedItem.value.imageUrl != null)
              Padding(
                padding: EdgeInsets.only(bottom: defaultPadding),
                child: AspectRatio(
                  aspectRatio: defaultImageAspectRatio,
                  child: Image.network(
                    _selectedItem.value.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Text(_selectedItem.value.content),
          ],
        ),
        width: double.infinity,
      ),
    );
  }

  Widget _buildToggleButtons(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      //Используем ValueListenableBuilder, чтобы при изменении _selectedItem обновлялся переключатель
      child: ValueListenableBuilder(
        valueListenable: _selectedItem,
        builder: (context, item, child) {
          return ToggleButtons(
            children: <Widget>[
              for (var itemModel in _items)
                Text(
                  _items.indexOf(itemModel).toString(),
                  style: TextStyle(color: Colors.white),
                ),
            ],
            onPressed: (index) {
              setState(() {
                //изменяем текущий выбранный элемент и обновляем интерфейс
                _selectedItem.value = _items[index];
              });
            },
            isSelected: List<bool>.generate(_items.length,
                (index) => (_items[index] == _selectedItem.value)),
          );
        },
      ),
    );
  }
}

class ItemModel {
  final String imageUrl;
  final String content;

  ItemModel({
    this.imageUrl,
    this.content,
  });
}
