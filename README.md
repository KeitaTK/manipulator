# マニピュレータシミュレーション プロジェクト

## 概要
このリポジトリは、マニピュレータ（ロボットアーム）のシミュレーションや運動学解析を行うためのMATLABスクリプトを中心に構成されています。主にロボットのDHパラメータ設定、モデル生成、可視化、運動学計算などを行います。

## ディレクトリ・ファイル構成
- LeggedRobot_211011/
  - New Folder/
    - m201016_test_DH_Params.m ・・・ DHパラメータからロボットモデルを生成・可視化
  - m0_symbolic_leggedRobot.m ・・・ シンボリック変数による順運動学・逆運動学計算

## 主なマニピュレータシミュレーション関連ファイル
- LeggedRobot_211011/New Folder/m201016_test_DH_Params.m
  - robotics.RigidBodyTreeを用いてDHパラメータからロボットモデルを生成し、showdetailsやshowで構造を可視化します。
- LeggedRobot_211011/m0_symbolic_leggedRobot.m
  - シンボリック変数を用いて順運動学（funcFwKine）やヤコビ行列の逆行列（funcJacbInvKine）を計算します。

## 使い方
1. MATLABで上記スクリプトを実行してください。
2. 必要に応じてDHパラメータやロボット構造を編集できます。

---
本READMEは自動生成されました。