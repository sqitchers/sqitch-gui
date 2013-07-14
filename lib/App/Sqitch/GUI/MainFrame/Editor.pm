package App::Sqitch::GUI::MainSplitter::LeftPane::Editor;

use Moose;
use Wx qw(:everything);
use Wx::STC;
use Wx::Event qw();

with 'App::Sqitch::GUI::Roles::Element';

has 'editor' => (is => 'rw', isa => 'Wx::StyledTextCtrl', lazy_build => 1);

sub BUILD {
    my $self = shift;
    return $self;
};

sub _build_editor {
    my $self = shift;

    my $sql_editor = Wx::StyledTextCtrl->new(
        $self->parent,
        -1,
        [ -1, -1 ],
        [ -1, -1 ],
    );

#     $sql_editor->SetMarginType( 1, wxSTC_MARGIN_SYMBOL );
#     $sql_editor->SetMarginWidth( 1, 10 );
#     $sql_editor->StyleSetFont( wxSTC_STYLE_DEFAULT,
#         Wx::Font->new( 10, wxDEFAULT, wxNORMAL, wxNORMAL, 0, 'Courier New' ) );
#     # $sql_editor->SetLexer( wxSTC_LEX_SQL );
#     $sql_editor->SetLexer( wxSTC_LEX_MSSQL );
#     # List0
#     $sql_editor->SetKeyWords(0,
#     q{all and any ascending between by cast collate containing day
# descending distinct escape exists from full group having in
# index inner into is join left like merge month natural not
# null on order outer plan right select singular some sort starting
# transaction union upper user where with year} );
#     # List1
#     $sql_editor->SetKeyWords(1,
#     q{blob char decimal integer number varchar} );
#     # List2 Only for MSSQL?
#     $sql_editor->SetKeyWords(2, q{avg count gen_id max min sum} );
#     $sql_editor->SetTabWidth(4);
#     $sql_editor->SetIndent(4);
#     $sql_editor->SetHighlightGuide(4);

#     $sql_editor->StyleClearAll();

#     # Global default styles for all languages
#     $sql_editor->StyleSetSpec( wxSTC_STYLE_BRACELIGHT,
#                                 "fore:#FFFFFF,back:#0000FF,bold" );
#     $sql_editor->StyleSetSpec( wxSTC_STYLE_BRACEBAD,
#                                 "fore:#000000,back:#FF0000,bold" );

#     # MSSQL - works with wxSTC_LEX_MSSQL
#     $sql_editor->StyleSetSpec(0, "fore:#000000");            #*Default
#     $sql_editor->StyleSetSpec(1, "fore:#ff7373,italic");     #*Comment
#     $sql_editor->StyleSetSpec(2, "fore:#007f7f,italic");     #*Commentline
#     $sql_editor->StyleSetSpec(3, "fore:#0000ff");            #*Number
#     $sql_editor->StyleSetSpec(4, "fore:#dca3a3");            #*Singlequoted
#     $sql_editor->StyleSetSpec(5, "fore:#3f3f3f");            #*Operation
#     $sql_editor->StyleSetSpec(6, "fore:#000000");            #*Identifier
#     $sql_editor->StyleSetSpec(7, "fore:#8cd1d3");            #*@-Variable
#     $sql_editor->StyleSetSpec(8, "fore:#705050");            #*Doublequoted
#     $sql_editor->StyleSetSpec(9, "fore:#dfaf8f");            #*List0
#     $sql_editor->StyleSetSpec(10,"fore:#94c0f3");            #*List1
#     $sql_editor->StyleSetSpec(11,"fore:#705030");            #*List2

    return $sql_editor;
}

sub _set_events {
    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable; 


1;
