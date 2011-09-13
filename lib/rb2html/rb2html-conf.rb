# -*- coding:utf-8 -*-

RB2HTML_CONFIG = {
  :normal_lang => {
    :rules => [
      [:numeric, {:class => 'num'}],
      [:comment, {:class => 'comment'}],
      [:string, {:class => 'str'}],
      [:keyword, {:class => 'kw'}],
      [:operator, {:class => 'op'}],
    ],
  },

  :java => {
    :base => :normal_lang,
    :rules => [
      [:annotation, {'class' => 'anno'}],
      [:kw_class, {:class => 'kw'}],
      [:kw_typename, {:class => 'kw'}],
      [:typename, {:class => 'typename'}],
    ]
  },

  :c => {
    :base => :normal_lang,
    :rules => [
      [:kw_op, {:class => 'kw'}],
      [:cpp, {:class => 'cpp'}],
    ]
  },

  :javascript => {
    :base => :normal_lang,
    :rules => [
      [:reserved, {:class => 'reserved'}],
      [:regex, {:class => 'regex'}],
    ],
  },

  :haskell => {
    :base => :normal_lang,
    :rules => [
      [:symbol, {'class' => 'sym'}],
    ]
  },

  :ruby => {
    :base => :normal_lang,
    :rules => [
      [:symbol ,           {:class => 'sym'}],
      [:here_mark,         {:class => 'str'}],
      [:class,             {:class => 'kw'}],
      [:regex,             {:class => 'reg'}],
      [:class_name,        {:class => 'cnm'}],
      [:comment,           {:class => 'com'}],
      [:constant,          {:class => 'con'}],
      [:instance_variable, {:class => 'ivar'}],
      [:class_variable,    {:class => 'cvar'}],
      [:global_variable,   {:class => 'gvar'}],
    ]
  },

  :python => {
    :base => :normal_lang,
    :rules => [
      [:operator, {:class => 'op'}],
      [:assignment, {:class => 'assign'}]
    ]
  },

  :css => {
    :rules => [
      [:comment, {'class'=>'comment'}],
      [:string, {'class'=>'str'}],
      [:property, {'class'=>'prop'}],
    ]
  },

  :html => {
    :base => :ruby,  # ERBのために
    :rules => [
      [:eruby, {:class=>'erb'}],
      [:tag_name, {'class'=>'tag'}],
      [:att_name, {'class'=>'aname'}],
      [:att_value, {'class'=>'aval'}]
    ]
  }
}
