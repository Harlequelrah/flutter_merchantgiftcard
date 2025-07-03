# GoChap GiftCard

GoChap lance sa dernière innovation , Une plateforme de carte cadeaux multi enseigne digital.

Cette plateforme est constituée d'une application web permettant à des souscripteurs (entreprises) de souscrire à des packages de carte cadeaux qu'ils peuvent offrir avec simplicié à des bénéficiaires (employés) .

Ces cartes cadeaux leur permettant d'effectuer des achats
par QrCode envoyés à leur adresse email ou par whatsapp ou encore directement dans l'interface mobile de leur application beneficiaire GoChap auprès de marchand acceptant ce mode de payement par le scan du QrCode depuis l'interface mobile de leur application marchande  GoChap.

# Technologies
- WebAPI de .NET pour la conception de l'API
- Blazor Server de .NET pour la conception de l'Application Web
- Flutter pour le dévéloppement des applications mobiles

# Installation
mkdir GoChapGiftCard
cd GoChapGiftCard
- API
  - git clone https://github.com/Harlequelrah/giftcard_api
  - cd giftcard_api
  - dotnet build
- Application Web
  - git clone https://github.com/Harlequelrah/blazor_giftcard
  - cd blazor giftcard
  - dotnet build
  - npm install
- Application Mobile Bénéficiaire
  - git clone https://github.com/Harlequelrah/flutter_giftcard
  - cd flutter_giftcard
  - flutter pub get
- Application Mobile Marchande
  - git clone https://github.com/Harlequelrah.flutter_merchantgiftcard
  - cd flutter_merchantgiftcard
  - flutter pub get

# Credit
- Bibliothèque .NET pour le développement de l'API
  - cd giftcard_api
  - dotnet list package
- Bibliothèque .NET pour le développement de l'application Web
  - cd blazor_giftcard
  - dotnet list package
- Biblitotheque Flutter pour le développement des applications mobiles
  - cd flutter_giftcard/flutter_merchantgiftcard
  - flutter pub deps

- Source externe
  - https://docs.flutter.dev
  - https://learn.microsoft.com/en-us/aspnet/core/blazor/?view=aspnetcore-8.0

# Utilisation
- Demarrage de l'API
  - cd giftcard_api
  - dotnet watch / dotnet run / dotnet watch run

- Demarrage de l'application web
  - cd blazor_giftcard
  - dotnet watch / dotnet run / dotnet watch run

- Demarrage de l'application mobile pour Bénéficiaire
  - cd flutter_giftcard
  - flutter run (Assurez vous de disposer d'un emulateur ou d'un appareil physique)
- Demarrage de l'application mobile pour Marchand
  - cd flutter_giftcard
  - flutter run (Assurez vous de disposer d'un emulateur ou d'un appareil physique)

# Screenshots 

![image](https://github.com/user-attachments/assets/0028eb23-22c4-4dab-b7f8-c6e3ad7421d8)

![image](https://github.com/user-attachments/assets/6b4302f5-1e1c-4362-9131-2056f0b4cce4)

![image](https://github.com/user-attachments/assets/c83c607f-ccaf-4214-bade-c4a30f4bed1a)

# Contact ou Support
Pour des questions ou du support, contactez-moi à maximeatsoudegbovi@gmail.com ou au (+228) 91 36 10 29.
