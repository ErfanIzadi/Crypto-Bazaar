import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/model/crypto.dart';

import '../data/constant/constants.dart';

class CoinListScreen extends StatefulWidget {
  CoinListScreen({Key? key, this.cryptoList}) : super(key: key);
  List<Crypto>? cryptoList;

  @override
  State<CoinListScreen> createState() => _CoinListScreenState();
}

class _CoinListScreenState extends State<CoinListScreen> {
  List<Crypto>? cryptoList;
  bool isSearchLoadingText = false;
  @override
  void initState() {
    super.initState();
    cryptoList = widget.cryptoList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        elevation: 25,
        backgroundColor: blackColor,
        title: Text(
          'کریپتو بازار',
          style: TextStyle(
            fontFamily: 'mr',
            fontSize: 24.5,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                onChanged: (value) {
                  _filterList(value);
                },
                decoration: InputDecoration(
                    hintText: 'نام رمز ارز معتبر خود را جست و جو کنید',
                    hintStyle: TextStyle(
                        fontFamily: 'mr', color: Colors.white, fontSize: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide(
                          width: 1,
                          style: BorderStyle.none,
                          color: Colors.white),
                    ),
                    filled: true,
                    fillColor: greenColor),
              ),
            ),
          ),
          Visibility(
            visible: isSearchLoadingText,
            child: Text(
              '... درحال بروز رسانی اطلاعات رمز ارز ها',
              style: TextStyle(color: greenColor, fontFamily: 'mr'),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              backgroundColor: greenColor,
              color: blackColor,
              onRefresh: () async {
                List<Crypto> freshData = await _getData();
                setState(() {
                  cryptoList = freshData;
                });
              },
              child: ListView.builder(
                itemCount: cryptoList!.length,
                itemBuilder: (context, index) {
                  return _getListTitleItem(
                    cryptoList![index],
                  );
                },
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget _getIconChangePercent(double percentChange) {
    return percentChange <= 0
        ? Icon(
            Icons.trending_down_outlined,
            size: 20,
            color: redColor,
          )
        : Icon(Icons.trending_up_outlined, size: 20, color: greenColor);
  }

  Color _getColorChangeText(double percentChange) {
    return percentChange <= 0 ? redColor : greenColor;
  }

  Widget _getListTitleItem(Crypto crypto) {
    return ListTile(
      title: Text(
        crypto.name,
        style: TextStyle(color: greenColor, fontSize: 22, fontFamily: 'arial'),
      ),
      subtitle: Text(
        crypto.symbol,
        style: TextStyle(color: greyColor2, fontSize: 15, fontFamily: 'arial'),
      ),
      leading: SizedBox(
        width: 30,
        child: Center(
          child: Text(
            crypto.rank.toString(),
            style: TextStyle(color: greyColor2, fontSize: 15),
          ),
        ),
      ),
      trailing: SizedBox(
        width: 145,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  crypto.priceUsd.toStringAsFixed(2),
                  style: TextStyle(color: greyColor2, fontSize: 18),
                ),
                Text(
                  crypto.changePercent24Hr.toStringAsFixed(2),
                  style: TextStyle(
                    color: _getColorChangeText(crypto.changePercent24Hr),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 35,
              child: Center(
                child: _getIconChangePercent(crypto.changePercent24Hr),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<List<Crypto>> _getData() async {
    var response = await Dio().get('https://api.coincap.io/v2/assets');
    List<Crypto> cryptoList = response.data['data']
        .map<Crypto>((jsonMapObject) => Crypto.fromMapJson(jsonMapObject))
        .toList();
    return cryptoList;
  }

  Future<void> _filterList(String enteredKeyword) async {
    List<Crypto> cryptoResultList = [];
    if (enteredKeyword.isEmpty) {
      setState(
        () {
          isSearchLoadingText = true;
        },
      );
      var result = await _getData();
      setState(
        () {
          cryptoList = result;
          isSearchLoadingText = false;
        },
      );
      return;
    }
    cryptoResultList = cryptoList!.where(
      (element) {
        return element.name.toLowerCase().contains(
              enteredKeyword.toLowerCase(),
            );
      },
    ).toList();
    setState(
      () {
        cryptoList = cryptoResultList;
      },
    );
  }
}
