package App::Sqitch::GUI::Types;

# ABSTRACT: Sqitch GUI Types

use 5.010;
use strict;
use warnings;
use utf8;
use Type::Library 0.040 -base, -declare => qw(
    Dir
    File
    Sqitch
    SqitchGUIConfig
    SqitchGUIController
    SqitchGUIDialogProject
    SqitchGUIDialogStatus
    SqitchGUIWxListctrl
    SqitchGUIModel
    SqitchGUIModelListDataTable
    SqitchGUIModelProjectItem
    SqitchGUIStatus
    SqitchGUITarget
    SqitchGUIView
    SqitchGUIViewPanelBottom
    SqitchGUIViewPanelChange
    SqitchGUIViewPanelLeft
    SqitchGUIViewPanelPlan
    SqitchGUIViewPanelProject
    SqitchGUIViewPanelRight
    SqitchGUIViewPanelTop
    SqitchGUIWxApp
    SqitchGUIWxEditor
    SqitchGUIWxNotebook
    SqitchGUIWxStatusbar
    SqitchGUIWxToolbar
    WxAboutDialogInfo
    WxButton
    WxCollapsiblePane
    WxComboBox
    WxDirPickerCtrl
    WxFrame
    WxGridSizer
    WxMenuBar
    WxPanel
    WxPoint
    WxRadioButton
    WxSize
    WxSizer
    WxSplitterWindow
    WxStaticLine
    WxStaticText
    WxStatusBar
    WxTextCtrl
    WxWindow
);
use Type::Utils -all;
use Types::Standard -types;
use Locale::TextDomain 1.20 qw(App-Sqitch-GUI);
use App::Sqitch::X qw(hurl);
#use App::Sqitch::Config;
#use Wx;

# Inherit standar types.
BEGIN { extends "Types::Standard" };

class_type Sqitch,            { class => 'App::Sqitch' };
class_type SqitchGUIWxApp,    { class => 'App::Sqitch::GUI::WxApp' };
class_type SqitchGUIView,     { class => 'App::Sqitch::GUI::View' };
class_type SqitchGUIModel,    { class => 'App::Sqitch::GUI::Model' };
class_type SqitchGUIModelListDataTable,
    { class => 'App::Sqitch::GUI::Model::ListDataTable' };
class_type SqitchGUIModelProjectItem,
    { class => 'App::Sqitch::GUI::Model::ProjectItem' };
class_type SqitchGUITarget,   { class => 'App::Sqitch::GUI::Target' };
class_type SqitchGUIWxListctrl,  { class => 'App::Sqitch::GUI::Wx::Listctrl' };
class_type SqitchGUIConfig,   { class => 'App::Sqitch::GUI::Config' };
class_type SqitchGUIController,
    { class => 'App::Sqitch::GUI::Controller' };
class_type SqitchGUIStatus,   { class => 'App::Sqitch::GUI::Status' };
class_type SqitchGUIDialogStatus,
    { class => 'App::Sqitch::GUI::View::Dialog::Status' };
class_type SqitchGUIDialogProject,
    { class => 'App::Sqitch::GUI::View::Dialog::Project' };
class_type SqitchGUIViewPanelLeft,
    { class => 'App::Sqitch::GUI::View::Panel::Left' };
class_type SqitchGUIViewPanelRight,
    { class => 'App::Sqitch::GUI::View::Panel::Right' };
class_type SqitchGUIViewPanelTop,
    { class => 'App::Sqitch::GUI::View::Panel::Top' };
class_type SqitchGUIViewPanelProject,
    { class => 'App::Sqitch::GUI::View::Panel::Project' };
class_type SqitchGUIViewPanelPlan,
    { class => 'App::Sqitch::GUI::View::Panel::Plan' };
class_type SqitchGUIViewPanelChange,
    { class => 'App::Sqitch::GUI::View::Panel::Change' };
class_type SqitchGUIViewPanelBottom,
    { class => 'App::Sqitch::GUI::View::Panel::Bottom' };
class_type SqitchGUIWxToolbar,
    { class => 'App::Sqitch::GUI::Wx::Toolbar' };
class_type SqitchGUIWxStatusbar,
    { class => 'App::Sqitch::GUI::Wx::Statusbar' };
class_type SqitchGUIWxNotebook,
    { class => 'App::Sqitch::GUI::Wx::Notebook' };
class_type SqitchGUIWxEditor,
    { class => 'App::Sqitch::GUI::Wx::Editor' };

# Wx
class_type WxAboutDialogInfo, { class => 'Wx::AboutDialogInfo' };
class_type WxButton,          { class => 'Wx::Button' };
class_type WxRadioButton      { class => 'Wx::RadioButton' };
class_type WxComboBox,        { class => 'Wx::ComboBox' };
class_type WxCollapsiblePane, { class => 'Wx::CollapsiblePane' };
class_type WxDirPickerCtrl,   { class => 'Wx::DirPickerCtrl' };
class_type WxGridSizer,       { class => 'Wx::GridSizer' };
class_type WxMenuBar,         { class => 'Wx::MenuBar' };
class_type WxPanel,           { class => 'Wx::Panel' };
class_type WxPoint,           { class => 'Wx::Point' };
class_type WxSize,            { class => 'Wx::Size' };
class_type WxSizer,           { class => 'Wx::Sizer' };
class_type WxSplitterWindow   { class => 'Wx::SplitterWindow' };
class_type WxStaticLine,      { class => 'Wx::StaticLine' };
class_type WxStaticText,      { class => 'Wx::StaticText' };
class_type WxStatusBar,       { class => 'Wx::StatusBar' };
class_type WxTextCtrl,        { class => 'Wx::TextCtrl' };
class_type WxWindow,          { class => 'Wx::Window' };
class_type WxFrame,           { class => 'Wx::Frame' };

# Other
class_type File, { class => 'Path::Class::File' };
class_type Dir,  { class => 'Path::Class::Dir'  };

1;

__END__

=head1 Name

App::Sqitch::Types - Definition of attribute data types

=head1 Synopsis

  use App::Sqitch::Types qw(Bool);

=head1 Description

This module defines data types use in Sqitch object attributes. Supported types
are:

=over

=item C<Sqitch>

An L<App::Sqitch> object.

=item C<Engine>

An L<App::Sqitch::Engine> object.

=item C<Target>

An L<App::Sqitch::Target> object.

=item C<UserName>

A Sqitch user name.

=item C<UserEmail>

A Sqitch user email address.

=item C<Plan>

A L<Sqitch::App::Plan> object.

=item C<Change>

A L<Sqitch::App::Plan::Change> object.

=item C<ChangeList>

A L<Sqitch::App::Plan::ChangeList> object.

=item C<LineList>

A L<Sqitch::App::Plan::LineList> object.

=item C<Tag>

A L<Sqitch::App::Plan::Tag> object.

=item C<Depend>

A L<Sqitch::App::Plan::Depend> object.

=item C<DateTime>

A L<Sqitch::App::DateTime> object.

=item C<URI>

A L<URI> object.

=item C<URIDB>

A L<URI::db> object.

=item C<File>

A C<Class::Path::File> object.

=item C<Dir>

A C<Class::Path::Dir> object.

=item C<Config>

A L<Sqitch::App::Config> object.

=item C<DBH>

A L<DBI> database handle.

=back

=head1 Author

David E. Wheeler <david@justatheory.com>

=head1 License

Copyright (c) 2012-2015 iovation Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

=cut
