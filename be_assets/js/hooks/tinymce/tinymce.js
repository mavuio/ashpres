// Import TinyMCE
import tinymce from 'tinymce/tinymce';

// Default icons are required for TinyMCE 5.3 or above
import 'tinymce/icons/default';

// A theme is also required
import 'tinymce/themes/silver';

// Any plugins you want to use has to be imported
// import 'tinymce/plugins/paste';

import 'tinymce/plugins/visualblocks'
import 'tinymce/plugins/code'
import 'tinymce/plugins/autosave'
import 'tinymce/plugins/link'

/*
things to make sure:

❖ add .tox-tinymce {
  z-index: 10000;
}

❖  copy skins to target:
skins need to be found at:
skin_url: '/be_thirdparty/tinymce/skins/ui/oxide',

*/

export default tinymce;
