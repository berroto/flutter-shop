import 'package:flutter/material.dart';
import 'package:flutter_shop_app/providers/product.dart';
import 'package:flutter_shop_app/providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";

  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionNode = FocusNode();
  final _imageNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var isInit = false;
  var _isLoading = false;
  Product _editedProduct =
      Product(id: "", title: "", description: "", imageUrl: "", price: 0);

  @override
  void initState() {
    _imageNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!isInit) {
      if ( ModalRoute
          .of(context)
          ?.settings
          .arguments != null) {
        final productId = ModalRoute
            .of(context)
            ?.settings
            .arguments as String;
        if (productId != null) {
          _editedProduct =
              Provider.of<Products>(context, listen: false).findById(productId);
          _imageUrlController.text = _editedProduct.imageUrl;
        }
      }
    }
    isInit = true;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _priceFocusNode.dispose();
    _descriptionNode.dispose();
    _imageNode.removeListener(_updateImageUrl);
    _imageNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm() async {
    final isValid = _form.currentState?.validate();
    if ( !isValid!){
      return;
    }
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    if ( _editedProduct.id == null || _editedProduct.id.isEmpty) {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error){
        return showDialog(context: context,
            builder: (ctx) => AlertDialog(title: Text("An error occured"),content: Text(error.toString()),actions: <Widget>[
              IconButton(onPressed: () {
                Navigator.of(ctx)
                    .pop();
              },
                icon: Icon(Icons.done),
                color: Theme.of(context).primaryColor,),]));
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    } else {
      try {
      Provider.of<Products>(context, listen: false).editProduct(_editedProduct);
      } catch (error){
        return showDialog(context: context,
            builder: (ctx) => AlertDialog(title: Text("An error occured"),content: Text(error.toString()),actions: <Widget>[
              IconButton(onPressed: () {
                Navigator.of(ctx)
                    .pop();
              },
                icon: Icon(Icons.done),
                color: Theme.of(context).primaryColor,),]));
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: _isLoading ? Center(
        child: CircularProgressIndicator(),
      ) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _editedProduct.title,
                decoration: InputDecoration(labelText: "Title"),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                validator: (value){
                  if (value == null || value.isEmpty){
                    return "Please put a value";
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                      id: _editedProduct.id,
                      isFavorite: _editedProduct.isFavorite,
                      title: value ?? "",
                      description: _editedProduct.description,
                      imageUrl: _editedProduct.imageUrl,
                      price: _editedProduct.price);
                },
              ),
              TextFormField(
                initialValue: _editedProduct.price.toString(),
                decoration: InputDecoration(labelText: "Price"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_descriptionNode);
                },
                validator: (value){
                  if (value == null || value.isEmpty){
                    return "Please enter a price";
                  }
                  if ( double.tryParse(value) == null){
                    return "Please enter a valid price";
                  }
                  if ( double.parse(value) <= 0){
                    return "Please enter a number greater then 0";
                  }

                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    id: _editedProduct.id,
                    isFavorite: _editedProduct.isFavorite,
                    title: _editedProduct.title,
                    description: _editedProduct.description,
                    imageUrl: _editedProduct.imageUrl,
                    price: double.parse(value ?? "0"),
                  );
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Description"),
                initialValue: _editedProduct.description,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionNode,
                onSaved: (value) {
                  _editedProduct = Product(
                      id: _editedProduct.id,
                      isFavorite: _editedProduct.isFavorite,
                      title: _editedProduct.title,
                      description: value ?? "",
                      imageUrl: _editedProduct.imageUrl,
                      price: _editedProduct.price);
                },
                validator: (value){
                  if (value == null || value.isEmpty){
                    return "Please put a description";
                  }
                  if ( value.length < 10 )
                    return "Please enter a description that is long enough ";
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(top: 8, right: 10),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey)),
                      child: _imageUrlController.text.isEmpty
                          ? Text("Enter URL here")
                          : FittedBox(
                              child: Image.network(_imageUrlController.text,
                                  fit: BoxFit.cover),
                            )),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: "Image URL"),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageNode,
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                      validator: (value){
                        if (value == null || value.isEmpty){
                          return "Please put an URL";
                        }
                        if ( !value.startsWith("http") && !value.startsWith("https") ){
                          return "Please put a valid URL";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            imageUrl: value ?? "",
                            price: _editedProduct.price);
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
