# README.md

## 諸注意

* [python対応バージョン](https://www.mathworks.com/content/dam/mathworks/mathworks-dot-com/support/sysreq/files/python-compatibility.pdf)
  - R2018a: 3.5, 3.6
  - R2022a: 3.8, 3.9
* FT232HのドライバはFTDI D2XXの`ftdibus.inf`を使用，標準ドライバで認識されるはず
* `openChannelFromSerial`の引数は`showDevices`で表示されるものを使用
* `cs`は接続に応じて設定変更する

## Matlabプログラム

### test

* test_PythonAPI.m: 対応バージョンのPythonが適切にmatlabに読み込まれていれば動く
* test_MPSSEandMcp3208.m: Mcp3208，ADCのテストプログラム．
* test_MPSSEandAeat6012.m: Aeat6012，磁気エンコーダのテストプログラム

### class

* classAeat6012.m: Aeat6012のクラスファイル
* classMcp3208.m: Mcp3208のクラスファイル

## Pythonプログラム

### test

* test_Mcp3208AndAeat6012.py: Mcp3208とAeat6012をそれぞれFT232H使ってテスト

### class

MPSSEMultiCh.py
Aeat6012.py
Mcp3208.py

## その他

* libMPSSE.dll: Pythonで読み込むDLL，Clangでビルド
* libMPSSE_spi.h: Cのheader
* 未修正Lsm9ds1.py: 9軸IMU
* 未修正Mcp23S08.py: GPIO拡張
