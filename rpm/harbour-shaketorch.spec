Name:       harbour-shaketorch

Summary:    Shake phone to turn flashlight on
Version:    0.3
Release:    2
License:    MIT
URL:        https://scarpino.dev
Source0:    %{name}-%{version}.tar.bz2
Source1:    harbour-shaketorch.service
Requires:   qt5-qtsensors-plugin-gestures-shake
BuildRequires:  pkgconfig(Qt5DBus)
BuildRequires:  pkgconfig(Qt5Gui)
BuildRequires:  pkgconfig(Qt5Sensors)
BuildRequires:  qt5-qttools-linguist

%description
Daemon process which turns on the flashlight when the
phone is shaken. It only works when the screen is turned on.

%if "%{?vendor}" == "chum"
PackageName: ShakeTorch
Type: desktop-application
DeveloperName: Andrea Scarpino
Categories:
 - Utility
Custom:
  Repo: https://github.com/ilpianista/harbour-ShakeTorch
Icon: https://raw.githubusercontent.com/ilpianista/harbour-ShakeTorch/master/icons/harbour-hauk.png
Screenshots:
 - https://raw.githubusercontent.com/ilpianista/harbour-ShakeTorch/master/screenshots/screenshot_1.png
 - https://raw.githubusercontent.com/ilpianista/harbour-ShakeTorch/master/screenshots/screenshot_2.png
Links:
  Homepage: https://github.com/ilpianista/harbour-ShakeTorch
  Bugtracker: https://github.com/ilpianista/harbour-ShakeTorch/issues
  Donation: https://liberapay.com/ilpianista
%endif

%prep
%setup -q -n %{name}-%{version}

%build

%qmake5

%make_build


%install
%qmake5_install

# >> install post
install -d %{buildroot}%{_userunitdir}
install -m644 %{SOURCE1} %{buildroot}%{_userunitdir}

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%{_userunitdir}/%{name}.service
# Settings plugin:
%{_datadir}/jolla-settings/entries/shaketorch.json
%dir %{_datadir}/jolla-settings/pages/shaketorch
%{_datadir}/jolla-settings/pages/shaketorch/*.qml
%{_datadir}/translations/settings-shaketorch*.qm


%post
systemctl-user daemon-reload
if [ $1 -eq 1 ]; then
systemctl-user enable --now %{name}.service
elif [ $1 -eq 2 ]; then
systemctl-user restart %{name}.service
fi

%preun
if [ $1 -eq 0 ]; then
  systemctl-user disable --now %{name}.service
fi

%postun
systemctl-user daemon-reload
