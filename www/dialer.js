var exec = require('cordova/exec');

module.exports = {
    call: function (number, success, error) {
        exec(success, error, "Dialer", "call", [number]);
    },

    /**
     * Open email composer via native intent / mail app.
     * @param {string} to - recipient email (single address)
     * @param {string} subject
     * @param {string} body
     */
    email: function (to, subject, body, success, error) {
        exec(
            success,
            error,
            "Dialer",
            "email",
            [to || "", subject || "", body || ""]
        );
    }
};
