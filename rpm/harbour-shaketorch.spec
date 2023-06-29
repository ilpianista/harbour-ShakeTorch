Name:       harbour-shaketorch

Summary:    Shake phone to turn on flashlight
Version:    0.1
Release:    1
License:    MIT
URL:        https://scarpino.dev
Source0:    %{name}-%{version}.tar.bz2
Source1:    harbour-shaketorch.service
Requires:  qt5-qtsensors-plugin-gestures-shake
BuildRequires:  pkgconfig(Qt5DBus)
BuildRequires:  pkgconfig(Qt5Gui)
BuildRequires:  pkgconfig(Qt5Sensors)

%description
Daemon process which turns on the flashlight when the
phone is shaken. It only works when the screen is turned on.


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
