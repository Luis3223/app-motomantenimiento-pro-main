const supabaseUrl = 'https://pboxtgmklnhfmeeomzam.supabase.co';
const supabasePublishableKey = 'sb_publishable_NfNwqsL8ctH_VhQxboFVxw_IKh-QdV5';

const pushRouteGarage = '/garage';
const pushRouteHistory = '/history';

/// ID del cliente OAuth de tipo "Aplicación web" en Google Cloud. Supabase
/// valida el ID token contra él. Vacío: el acceso con Google queda desactivado.
const googleWebClientId =
    '903873743770-550gqm7v1mc2vccid31qpvoupab4per4.apps.googleusercontent.com';

/// Deep link del enlace de recuperación de contraseña. Debe coincidir con el
/// `intent-filter` de `AndroidManifest.xml` y estar en las Redirect URLs de
/// Supabase Auth.
const passwordResetRedirect =
    'com.aistudio.motomantenimiento.pkmvqw://reset-password';
