<?php
function mysql_check_result ($connection, $result) {

    if ( ! $result ) {

        echo "Błąd: " . mysqli_error($connection);

        return false;
    } else {
        return $result;
    }

}

function selectf($connection, $tName, $csh, $whereValue = 'true') {

    $query = "SELECT " . $csh . " FROM " . $tName . " WHERE " . $whereValue . ";";

    $result = mysqli_query($connection, $query);

    return $result;

}

function isInteger($value) {

    if ( ! preg_match('/\D/', $value) ) {
        return true;
    } else {
        return false;
    }

}

function insertf($connection, $tName, $csh, $pKL) {

    $cshTab = explode(',', $csh);
    $pklTab = explode(',', $pKL);

    $query = "INSERT INTO " . $tName . " (" . $csh . ") VALUES (";

    for ($i=0; $i < count($pklTab); $i++) {

        if ( $i === ( count($pklTab) - 1) ) {
            if ( isInteger($_POST[$pklTab[$i]]) ) {
                $query .= $_POST[$pklTab[$i]];
            } else {
                $query .= "'" .  $_POST[$pklTab[$i]] . "'";
            }
        } else {
            if ( isInteger($_POST[$pklTab[$i]]) ) {
                $query .= $_POST[$pklTab[$i]] . ",";
            } else {
                $query .= "'" . $_POST[$pklTab[$i]] . "',";
            }
        }

    }

    $query .= ");";

    $result = mysqli_query($connection, $query);

    return $result;
}

function generatePKL($tName, $csh) {

    $cshTable = explode(',', $csh);

    for($i=0; $i < count($cshTable); $i++) {

        if ( $i === 0 ) {
            if ( $i === ( count($cshTable) - 1) ) {
                $pKL = $tName . "_" . $cshTable[$i];
            } else {
                $pKL = $tName . "_" . $cshTable[$i] . ",";
            }
        } else {
            if ( $i === ( count($cshTable) - 1) ) {
                $pKL .= $tName . "_" . $cshTable[$i];
            } else {
                $pKL .= $tName . "_" . $cshTable[$i] . ",";
            }
        }

    }

    return $pKL;

}

function updatef($connection, $tName, $csh, $pKL, $whereValue) {

    $cshTab = explode(',', $csh);
    $pklTab = explode(',', $pKL);

    $query = "UPDATE " . $tName . " SET ";

    for($i=0; $i < count($pklTab); $i++) {

       if ( $i === (count($pklTab) - 1) ) {
            if ( isInteger($_POST[$pklTab[$i]]) ) {
                $query .= $cshTab[$i] . '=' . $_POST[$pklTab[$i]];
            } else {
                $query .= $cshTab[$i] . "='". $_POST[$pklTab[$i]] . "'";
            }
        } else {
            if ( isInteger($_POST[$pklTab[$i]]) ) {
                $query .= $cshTab[$i] . '=' . $_POST[$pklTab[$i]] . ",";
            } else {
                $query .= $cshTab[$i] . "='". $_POST[$pklTab[$i]] . "',";
            }
        }

    }

    $query .= " WHERE " . $whereValue;

    $result = mysqli_query($connection, $query);

    return $result;

}


function deletef($connection, $tName, $whereValue) {

    $query = 'DELETE FROM ' . $tName . ' WHERE ' . $whereValue;

    $result = mysqli_query($connection, $query);

    return $result;

}

?>